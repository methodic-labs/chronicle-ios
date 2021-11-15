//
//  SensorDataManager.swift
//  SensorDataManager
//
//  Created by Alfonce Nzioka on 11/10/21.
//

//
//  SensorDataManager.swift
//  SensorDataManager
//
//  Created by Alfonce Nzioka on 11/10/21.
//

import Foundation
import SensorKit
import OSLog
import CoreData

// handles all functionality related to sensor data: user authorization, configuring sensors for recording, fetching recorded data to Core Data, and uploading to server based on scheduled timer
// TODO: configure authorized sensors to record data: https://developer.apple.com/documentation/sensorkit/srsensorreader

class SensorDataManager: NSObject, SRSensorReaderDelegate {
    
    // access to CoreData stack
    var persistenceController: PersistenceController = .shared
    
    // shared instance
    static var shared = SensorDataManager()
    
    // due to CoreData concurrency issues, we want to prevent multiple threads from attempting to fetch the same data before the server's upload request returns
    private var uploadingData: Bool
    
    private init(uploadingData: Bool = false) {
        self.uploadingData = uploadingData
    }
    
    // TODO: replace this with values from EDM
    // https://github.com/openlattice/chronicle-ios/pull/6 fetches required PTIDs and saves them on device
    let variablePTID = "f3c1a844-8c32-4d7a-b18f-68d4cc031daf"
    let valuesPTID = "dcc3bc24-3a5d-45cf-8e38-bc9ba8c43d06"
    let endDateTimePTID = "0ee3acba-51a7-4f8d-921f-e23d75b07f65"
    let startDateTime = "92a6a5c5-b4f1-40ce-ace9-be232acdce2a"
    let idPTID = "39e13db7-a730-421a-a600-ae0674060140"
    let namePTID = "ddb5d841-4c82-407c-8fcb-58f04ffc20fe"
    let dateLoggedPTID = "e90a306c-ee37-4cd1-8a0e-71ad5a180340"
    
    // logging
    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorDataManager")
    
    // max number of items to fetch from data store
    let fetchLimit = 1000
    
    // This function is called when SRSensor.fetch returns a fetch result
    // SensorKit places a 24-hour holding period on newly recorded data before it is available for fetching.
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        // TODO: handle different types of sample types. import to CoreData
        return true
    }
    
    // invoked when SrSensor.fetch fails
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        //TODO: handle fetch error
    }
    
    // creates fake sensor data and saves to disk.
    @objc func mockSensorData() {
        logger.info("mocking sensor data")
        
        guard let taskContext = persistenceController.newTaskContext() else {
            logger.error("Unable to create task context")
            return
        }
        
        let sensors = ["visits", "deviceUsage"]
        
        // this is executed on a separate thread
        taskContext.performAndWait {
            logger.info("start mock")
            
            do {
                for _ in 0..<100 {
                    let sensor = sensors.randomElement()!
                    
                    let object = SensorData(context: taskContext)
                    object.writeTimestamp = Utils.convertDateToString(Date())
                    object.endTimestamp = Utils.convertDateToString(Date())
                    object.startTimestamp = Utils.convertDateToString(Date())
                    object.id = UUID.init().uuidString
                    object.data = sensor == "visits" ? self.createVisitsSensorMockData() : self.createDeviceUsageSensorMockData()
                    object.sensorType = sensor
                }
                
                try taskContext.save()
                self.logger.log("saved mock data in Core Data")
            } catch let error {
                self.logger.log("Failed to save data in background: \(error.localizedDescription)")
            }
        }
        
    }
    
    // attempt to upload currently stored data to db
    @objc func uploadMockSensorData (timer: Timer)  {
        if uploadingData {
            logger.info("data upload in progress. exiting")
            return
        }
        
        logger.info("starting data upload")
        
        let userInfo = timer.userInfo as? [String: Any] ?? [:]
        let deviceId = userInfo["deviceId"] as? String ?? ""
        
        guard !deviceId.isEmpty else {
            logger.error("invalid deviceId. Aborting data upload")
            return
        }
        
        let enrollment = Enrollment.getCurrentEnrollment()
        
        guard let taskContext = persistenceController.backgroundContext else {
            logger.error("unable to upload data: task context cannot be initialized")
            return
        }
        
        taskContext.performAndWait {
            uploadingData = true
            do {
                let fetchRequest: NSFetchRequest<SensorData>
                fetchRequest = SensorData.fetchRequest()
                fetchRequest.fetchLimit = fetchLimit
                
                let objects = try taskContext.fetch(fetchRequest)
                
                
                if objects.isEmpty {
                    self.logger.info("no more available data to upload. exiting")
                    self.uploadingData = false
                    return
                }

                let data = try self.transformSensorDataForUpload(objects)
                                
                ApiClient.uploadData(sensorData: data, enrollment: enrollment, deviceId: deviceId) {

                    self.logger.info("Successfully uploaded \(objects.count) sensor data objects")
                    UserDefaults.standard.set(Utils.convertDateToString(Date()), forKey: UserSettingsKeys.lastUploadDate)

                    objects.forEach(taskContext.delete)
                    self.logger.info("Deleted from the store")

                    try? taskContext.save()
                    
                    self.uploadingData = false

                } onError: {
                    self.logger.info("Upload failure: \($0)")
                    self.uploadingData = false
                }
                
            } catch let error {
                self.logger.log("failed to upload data to server: \(error.localizedDescription)")
                
            }
        }
    }
    
    func transformSensorDataForUpload(_ data: [SensorData]) throws -> Data {
        
        let transformed: [[String: Any]] = try data.map {
            var result: [String: Any] = [:]
            
            if let dateRecorded = $0.writeTimestamp,
               let startDate = $0.startTimestamp,
               let endDate = $0.endTimestamp,
               let sensor = $0.sensorType,
               let id = $0.id,
               let data = $0.data {
                
                let toJSon = try JSONSerialization.jsonObject(with: data, options: [])
                
                result[namePTID] = sensor
                result[dateLoggedPTID] = dateRecorded
                result[startDateTime] = startDate
                result[endDateTimePTID] = endDate
                result[idPTID] = id
                result[valuesPTID] = toJSon
            }
            return result
        }
        
        return try JSONSerialization.data(withJSONObject: transformed, options: [])
    }
    
    // mock data on user's travel routine: https://developer.apple.com/documentation/sensorkit/srvisit
    func createVisitsSensorMockData() ->  Data {
        
        let locationCategories = ["gym", "home", "school", "work", "unknown"]
        
        let data = [
            [variablePTID: "distanceFromHome", valuesPTID: 13222],
            [variablePTID: "arrivalDateIntervalStart", valuesPTID: Utils.convertDateToString(Date())],
            [variablePTID: "arrivalDateIntervalEnd", valuesPTID: Utils.convertDateToString(Date().addingTimeInterval(200))],
            [variablePTID: "departureDateIntervalStart", valuesPTID: Utils.convertDateToString(Date().addingTimeInterval(3600))],
            [variablePTID: "departureDateIntervalEnd", valuesPTID: Utils.convertDateToString(Date().addingTimeInterval(4200))],
            [variablePTID: "locationCategory", valuesPTID: locationCategories.randomElement()!]
        ]
        
        return try! JSONSerialization.data(withJSONObject: data, options: [])
    }
    
    //mock data on user's device usage: https://developer.apple.com/documentation/sensorkit/srdeviceusagereport
    func createDeviceUsageSensorMockData() -> Data {
        
        let data = [
            [variablePTID: "intervalStart", valuesPTID: Utils.convertDateToString(Date())],
            [variablePTID: "intervalEnd", valuesPTID: Utils.convertDateToString(Date().addingTimeInterval(3600))],
            [variablePTID: "totalScreenWakes", valuesPTID: 10],
            [variablePTID: "totalUnlocks", valuesPTID: 5],
        ]
        
        return try! JSONSerialization.data(withJSONObject: data, options: [])
    }
}
