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
