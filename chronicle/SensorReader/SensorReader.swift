//
//  File.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit
import OSLog

struct SensorReader {
    private let appDelegate: AppDelegate
    
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorReader")
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    
    func initialize() {
        /// displays a prompt to request for user approval
        /// Prompt is not displayed if user has already responded by either approving/denying access
        
        let sensorReaderDelegate = SensorReaderDelegate(appDelegate: appDelegate)
        
        SRSensorReader.requestAuthorization(sensors: availableSensors ) { (error: Error?) -> Void in
            if let error = error {
                logger.info("Authorization failed: \(error.localizedDescription)")
            }
            
            availableSensors.forEach { sensor in
                let reader = SRSensorReader(sensor: sensor)
                
                reader.delegate = sensorReaderDelegate
                reader.startRecording()
            }
        }
    }
}

extension SensorReader {
    var availableSensors: Set<SRSensor> {
        return [
            .deviceUsageReport,
            .messagesUsageReport,
            .phoneUsageReport,
            .keyboardMetrics
        ]
    }
    
    // mapping from sensor to friendly name
    static var sensorNameMapping: [SRSensor:Sensor] {
        return [
            .deviceUsageReport: Sensor.deviceUsage,
            .messagesUsageReport: Sensor.messagesUsage,
            .phoneUsageReport: Sensor.phoneUsage,
            .keyboardMetrics: Sensor.keyboardMetrics
        ]
    }
}

