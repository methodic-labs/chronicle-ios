//
//  SensorReaderDelegate.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit
import OSLog

/**
  This class responds to sensor-related events
 */
class SensorReaderDelegate: NSObject, SRSensorReaderDelegate {
    private let appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorReader")
    
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        logger.info("started recording \(reader.sensor.rawValue)")
    }
    
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        logger.info("stopped recording \(reader.sensor.rawValue)")
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        
        let sensor = reader.sensor
        let timestamp = result.timestamp
        let sample = result.sample
        
        var sensorDataProperties: SensorDataProperties?

        switch sensor {
        case .phoneUsageReport:
            sensorDataProperties = SensorDataConverter.getPhoneUsageData(sample: sample as! SRPhoneUsageReport, timestamp: timestamp)
        case .keyboardMetrics:
            sensorDataProperties = SensorDataConverter.getKeyboardMetricsData(sample: sample as! SRKeyboardMetrics, timestamp: timestamp)
        case .deviceUsageReport:
            sensorDataProperties = SensorDataConverter.getDeviceUsageData(sample: sample as! SRDeviceUsageReport, timestamp: timestamp)
        case .messagesUsageReport:
            sensorDataProperties = SensorDataConverter.getMessagesData(sample: sample as! SRMessagesUsageReport, timestamp: timestamp)
        default:
            print("sensor \(sensor) is not supported")
        }
        
        guard let sensorDataProperties = sensorDataProperties else {
            return true
        }
        
        if (sensorDataProperties.isValidSample) {
            appDelegate.importIntoCoreData(data: sensorDataProperties)
        }

        return true
    }
}
