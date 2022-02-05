//
//  ImportIntoCoreDataOperation.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 2/1/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import CoreData
import OSLog

class ImportIntoCoreDataOperation: Operation {
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "ImportIntoCoreDataOperation")
    private let context: NSManagedObjectContext
    private let sensorDataProperties: SensorDataProperties
    
    init(context: NSManagedObjectContext, data: SensorDataProperties) {
        self.context = context
        self.sensorDataProperties = data
    }
    
    override func main() {
        // what what
        context.performAndWait {
            do {
                let object = SensorData(context: context)
                object.id = sensorDataProperties.id
                object.data = sensorDataProperties.data
                object.duration = sensorDataProperties.duration
                object.sensorType = sensorDataProperties.sensor.rawValue
                object.timezone = sensorDataProperties.timezone
                object.writeTimestamp = sensorDataProperties.writeTimestamp
                object.endDate = sensorDataProperties.endDate
                object.startDate = sensorDataProperties.startDate
                object.device = sensorDataProperties.device
                
                try context.save()
                logger.info("imported \(self.sensorDataProperties.toString()) into core data")
            } catch {
                self.logger.error("error importing sensor data to core data \(self.sensorDataProperties.toString())")
            }
        }
    }
}
