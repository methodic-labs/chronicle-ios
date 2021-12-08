//
//  Operations.swift
//  Operations
//
//  Created by Alfonce Nzioka on 11/16/21.
//

/*
 classes and functions for fetching and adding sensor data entries to database
 */
import Foundation
import CoreData
import OSLog

class MockSensorDataOperation: Operation {
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "MockSensorDataOperation")

    private let context: NSManagedObjectContext

    private var timezone: String {
        TimeZone.current.identifier
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func main() {

        let numEntries = Int.random(in: 200...300)
        context.performAndWait {
            do {
                for _ in 0..<numEntries {
                    let now = Date()
                    let start = now - (60 * 60) // 1hr before
                    let end = now + (60 * 60) // 1hr after
                    let sensorType = SensorType.allCases.randomElement()!

                    let object = SensorData(context: context)
                    object.id = UUID.init()
                    object.sensorType = sensorType.rawValue
                    object.startTimestamp = start
                    object.endTimestamp = end
                    object.writeTimestamp = now
                    object.timezone = timezone
                    object.data = SensorDataMock.createMockData(sensorType: sensorType)

                    try context.save()
                }
                logger.info("saved \(numEntries) SensorData objects to database")

            } catch {
                logger.error("error saving mock data to database: \(error.localizedDescription)")
            }
        }
    }
}

class UploadDataOperation: Operation {
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "UploadDataOperation")

    private let context: NSManagedObjectContext
    private var propertyTypeIds: [FullQualifiedName: UUID] = [:]

    private let fetchLimit = 200

    private var uploading = false
    private var hasMoreData = false

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    override func start() {
        willChangeValue(forKey: #keyPath(isExecuting))
        self.hasMoreData = true
        didChangeValue(forKey: #keyPath(isExecuting))
        // get property type ids
        Task.init {
            self.propertyTypeIds = await (ApiClient.getPropertyTypeIds() ?? [:])
            main()
        }
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
        context.performAndWait {
            do {
                while hasMoreData {
                    let fetchRequest: NSFetchRequest<SensorData>
                    fetchRequest = SensorData.fetchRequest()
                    fetchRequest.fetchLimit = fetchLimit

                    let objects = try context.fetch(fetchRequest)

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
                    let data = try transformSensorDataForUpload(objects)

                    self.logger.info("attempting to upload \(objects.count) objects to server")
                    self.uploading = true
                    UserDefaults.standard.set(true, forKey: UserSettingsKeys.isUploading)

                    ApiClient.uploadData(sensorData: data, enrollment: enrollment, deviceId: deviceId) {
                        self.logger.info("successfully uploaded \(objects.count) to server")
                        objects.forEach (self.context.delete) // delete uploaded data from local db
                        try? self.context.save()
                        // record last successful upload
                        UserDefaults.standard.set(Date().toISOFormat(), forKey: UserSettingsKeys.lastUploadDate)
                        self.uploading = false
                        UserDefaults.standard.set(false, forKey: UserSettingsKeys.isUploading)
                    } onError: { error in
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

    private func transformSensorDataForUpload(_ data: [SensorData]) throws -> Data {
        let transformed: [Sample?] = try data.map {

            if let dateRecorded = $0.writeTimestamp,
               let startDate = $0.startTimestamp,
               let endDate = $0.endTimestamp,
               let sensor = $0.sensorType,
               let id = $0.id,
               let timezone = $0.timezone,
               let data = $0.data {

                let valuesArr = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: String]]

                return Sample(dateRecorded: dateRecorded.toISOFormat(), startDate: startDate.toISOFormat(), endDate: endDate.toISOFormat(), data: valuesArr, timezone: timezone, id: id, sensorName: sensor)
            }

            return nil
        }.filter { $0 != nil }

        return try JSONEncoder().encode(transformed)
    }

}

struct Sample: Encodable {
    var dateRecorded: String
    var startDate: String
    var endDate: String
    var data: [[String: String]]
    var timezone: String
    var id: UUID
    var sensorName: String
}


extension Date {

    // return random date between two dates
    static func randomBetween(start: Date, end: Date) -> Date {
        var date1 = start
        var date2 = end
        if date2 < date1 {
            swap(&date1, &date2)
        }

        let span = TimeInterval.random(in: date1.timeIntervalSinceNow...date2.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: span)
    }

    func toISOFormat() -> String {
        return ISO8601DateFormatter.init().string(from: self)
    }
}
