//
//  SensorDataProvider.swift
//  SensorDataProvider
//
//  Created by Alfonce Nzioka on 11/10/21.
//

//
//  SensorDataProvider.swift
//  SensorDataProvider
//
//  Created by Alfonce Nzioka on 11/10/21.
//

import Foundation
import SensorKit
import OSLog
import CoreData

// handles all functionality related to sensor data: user authorization, configuring sensors for recording, fetching recorded data to Core Data, and uploading to server based on scheduled timer

class SensorDataProvider: NSObject, SRSensorReaderDelegate {
    
    // access to CoreData stack
    let persistenceController: PersistenceController = .shared
    
    // shared instance
    static var shared = SensorDataProvider()
    
    // TODO: replace this with values from EDM
    let variablePTID = UUID.init(uuidString: "f3c1a844-8c32-4d7a-b18f-68d4cc031daf")
    let valuesPTID = UUID.init(uuidString: "dcc3bc24-3a5d-45cf-8e38-bc9ba8c43d06")
    let endDateTimePTID = UUID.init(uuidString: "0ee3acba-51a7-4f8d-921f-e23d75b07f65")
    let startDateTime = UUID.init(uuidString: "92a6a5c5-b4f1-40ce-ace9-be232acdce2a")
    let idPTID = UUID.init(uuidString: "39e13db7-a730-421a-a600-ae0674060140")
    let namePTID = UUID.init(uuidString: "ddb5d841-4c82-407c-8fcb-58f04ffc20fe")
    let dateLoggedPTID = UUID.init(uuidString: "e90a306c-ee37-4cd1-8a0e-71ad5a180340")
    
    
    // logging
    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorDataProvider")
    
    override private init() {
        super.init()
    }
    
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
             
        // this is executed on a separate thread
        taskContext.performAndWait {

            do {
                for _ in 0..<10 {
                    let object = SensorData(context: taskContext)
                    object.writeTimestamp = Utils.convertDateToString(Date())
                    object.endTimestamp = Utils.convertDateToString(Date())
                    object.startTimestamp = Utils.convertDateToString(Date())
                    object.id = UUID.init().uuidString
                    object.data = self.createMockData()
                    object.sensorType = "visits"
                }
                
                try taskContext.save()
                self.logger.log("saved mock data in Core Data")
            } catch let error {
                self.logger.log("Failed to save data in background: \(error.localizedDescription)")
            }
        }
        
    }
    
    
    func createMockData() ->  Data {
        // create an array of objects
        var data: [[String: Any]] = []

        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600)
        
        data.append([variablePTID!.uuidString: "distanceFromHome", valuesPTID!.uuidString: 13222])
        data.append([variablePTID!.uuidString: "arrivalDateInterval", valuesPTID!.uuidString: DateInterval(start: startDate, end: endDate).description])
        data.append([variablePTID!.uuidString: "locationCategory", valuesPTID!.uuidString: "gym"])
        
        return try! JSONSerialization.data(withJSONObject: data, options: [])
    }
    
}
