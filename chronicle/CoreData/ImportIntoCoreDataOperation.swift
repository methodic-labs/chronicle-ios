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
                object.id = UUID.init()
                object.data = sensorDataProperties.data
                object.device = sensorDataProperties.device
                object.duration = sensorDataProperties.duration
                object.sensorType = sensorDataProperties.sensor.rawValue
                object.timezone = sensorDataProperties.timezone
                object.writeTimestamp = sensorDataProperties.writeTimestamp
                
                try context.save()
            } catch {
                self.logger.error("error importing sensor data to core data \(self.sensorDataProperties.toString())")
            }
        }
    }
}
