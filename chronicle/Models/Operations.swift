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
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    override func main() {
        
        let numEntries = Int.random(in: 50...100)
        context.performAndWait {
            do {
                for _ in 0..<numEntries {
                    let now = Date()
                    let start = now - (60 * 60) // 1hr before
                    let end = now + (60 * 60) // 1hr after
                    let sensorType = SensorType.allCases.randomElement()!
                    
                    let object = SensorData(context: context)
                    object.id = UUID.init().uuidString
                    object.sensorType = sensorType.rawValue
                    object.startTimestamp = start.toISOFormat()
                    object.endTimestamp = end.toISOFormat()
                    object.writeTimestamp = now.toISOFormat()
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
    private let deviceId: String
    private let enrollment: Enrollment
    
    private let fetchLimit = 200
    
    private var uploading = false
    private var hasMoreData = true
    
    init(context: NSManagedObjectContext, deviceId: String, enrollment: Enrollment) {
        self.context = context
        self.deviceId = deviceId
        self.enrollment = enrollment
    }
    
    override func main() {
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
                        self.hasMoreData = false
                        self.uploading = false
                        break
                    }
                    
                    // transform to Data
                    let data = try transformSensorDataForUpload(objects)
                    
                    self.logger.info("attempting to upload \(objects.count) objects to server")
                    self.uploading = true
                    
                    ApiClient.uploadData(sensorData: data, enrollment: enrollment, deviceId: deviceId) {
                        objects.forEach (self.context.delete) // delete uploaded data from local db
                        try? self.context.save()
                        self.uploading = false
                    } onError: { error in
                        self.logger.error("error uploading to server: \(error)")
                        
                        // signal operation to terminate
                        self.uploading = false
                        self.hasMoreData = false
                    }
                    
                    // wait until the current upload attempt complete, and try again if there is more data
                    while self.uploading {
                        Thread.sleep(forTimeInterval: 5000)
                    }
                }
                
            } catch {
                logger.error("error uploading data to server: \(error.localizedDescription)")
                uploading = false
            }
        }
    }
    
    override var isExecuting: Bool {
        return uploading || hasMoreData
    }
    
    private func transformSensorDataForUpload(_ data: [SensorData]) throws -> Data {
        
        let transformed: [[String: Any]] = try data.map {
            var result: [String: Any] = [:]
            
            if let dateRecorded = $0.writeTimestamp,
               let startDate = $0.startTimestamp,
               let endDate = $0.endTimestamp,
               let sensor = $0.sensorType,
               let id = $0.id,
               let data = $0.data {
                
                let toJSon = try JSONSerialization.jsonObject(with: data, options: [])
                
                result[PropertyTypeIds.namePTID] = sensor
                result[PropertyTypeIds.dateLoggedPTID] = dateRecorded
                result[PropertyTypeIds.startDateTime] = startDate
                result[PropertyTypeIds.endDateTimePTID] = endDate
                result[PropertyTypeIds.idPTID] = id
                result[PropertyTypeIds.valuesPTID] = toJSon
            }
            return result
        }
        
        return try JSONSerialization.data(withJSONObject: transformed, options: [])
    }
    
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
