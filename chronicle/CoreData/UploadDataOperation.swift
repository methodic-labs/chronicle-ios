//
//  UploadDataOperation.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 2/1/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import Foundation
import CoreData
import OSLog
import FirebaseAnalytics

class UploadDataOperation: Operation {
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "UploadDataOperation")

    private let bgContext: NSManagedObjectContext
    private let viewContext: NSManagedObjectContext

    private let fetchLimit = 50

    private var uploading = false
    private var hasMoreData = false

    init(bgContext: NSManagedObjectContext, viewContext: NSManagedObjectContext) {
        self.bgContext = bgContext
        self.viewContext = viewContext
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        self.hasMoreData = true
        didChangeValue(forKey: #keyPath(isExecuting))
        main()
    }


    override func main() {
        let deviceId = UserDefaults.standard.object(forKey: UserSettingsKeys.deviceId) as? String ?? ""
        guard !deviceId.isEmpty else {
            logger.error("invalid deviceId")
            return
        }

        let enrollment = Enrollment.getCurrentEnrollment()
        guard enrollment.isValid else {
            logger.error("unable to retrieve enrollment details")
            return
        }

        // try fetching
        bgContext.performAndWait {
            do {
                while hasMoreData {
                    let fetchRequest: NSFetchRequest<SensorData>
                    fetchRequest = SensorData.fetchRequest()
                    fetchRequest.fetchLimit = fetchLimit

                    let objects = try bgContext.fetch(fetchRequest)
                    
                    var params = enrollment.toDict()
                    params.merge(["count": objects.count.description]) { (new, _) in new }
                    Analytics.logEvent(FirebaseAnalyticsEvent.didFetchFromCoreData.rawValue, parameters: params)

                    // no data available. signal operation to terminate
                    if objects.isEmpty {
                        willChangeValue(forKey: #keyPath(isExecuting))
                        willChangeValue(forKey: #keyPath(isFinished))
                        self.hasMoreData = false
                        self.uploading = false
                        didChangeValue(forKey: #keyPath(isExecuting))
                        didChangeValue(forKey: #keyPath(isFinished))
                        break
                    }

                    if isCancelled {
                        break
                    }

                    // transform to Data
                    let data = Datasource.encodeArray(arr: objects)
                    guard let data = data else {
                        throw "invalid data"
                    }


                    self.logger.info("attempting to upload \(objects.count) objects to server")
                    self.uploading = true
                    UserDefaults.standard.set(true, forKey: UserSettingsKeys.isUploading)

                    var eventLogParams = enrollment.toDict() // { participantId: xx, studyId: xx }
                    
                    ApiClient.uploadData(sensorData: data, enrollment: enrollment, deviceId: deviceId) {
                        eventLogParams.merge(["upload_size_bytes": data.count.description]) { (current, _) in current }
                        Analytics.logEvent(FirebaseAnalyticsEvent.uploadData.rawValue, parameters: eventLogParams)
                        
                        self.logger.info("successfully uploaded \(objects.count) to server")
                        
                        // save upload stats
                        let uploadDate = Date()
                        let stats = Dictionary(grouping: objects, by: { $0.sensorType }).compactMapValues { values in
                            UploadStatEvent(timestamp: uploadDate, sensorType: (values.first?.sensorType)!, samples: values.count)
                        }
                        let statObjects = UploadHistory(context: self.viewContext)
                        statObjects.timestamp = uploadDate
                        statObjects.data = try? JSONEncoder().encode(stats)
                        try? self.viewContext.save()
                        
                        objects.forEach (self.bgContext.delete) // delete uploaded data from local db
                        try? self.bgContext.save()
                        // record last successful upload
                        UserDefaults.standard.set(uploadDate.toISOFormat(), forKey: UserSettingsKeys.lastUploadDate)
                        self.uploading = false
                        UserDefaults.standard.set(false, forKey: UserSettingsKeys.isUploading)
                    } onError: { error in
                        eventLogParams.merge(["upload_error": error.debugDescription]) {(current, _) in current}
                        Analytics.logEvent(FirebaseAnalyticsEvent.uploadDataFailure.rawValue, parameters: eventLogParams)
                        
                        self.logger.error("error uploading to server: \(error)")

                        // signal operation to terminate
                        self.willChangeValue(forKey: #keyPath(isExecuting))
                        self.willChangeValue(forKey: #keyPath(isFinished))
                        self.uploading = false
                        self.hasMoreData = false
                        self.didChangeValue(forKey: #keyPath(isExecuting))
                        self.didChangeValue(forKey: #keyPath(isFinished))
                        
                        UserDefaults.standard.set(false, forKey: UserSettingsKeys.isUploading)
                    }

                    // wait until the current upload attempt complete, and try again if there is more data
                    while self.uploading {
                        Thread.sleep(forTimeInterval: 5)
                    }
                }

            } catch {
                logger.error("error uploading data to server: \(error.localizedDescription)")
                uploading = false
            }
        }
    }

    override var isExecuting: Bool {
        return hasMoreData
    }

    override var isAsynchronous: Bool {
        return true
    }

    override var isFinished: Bool {
        return !hasMoreData
    }

}
