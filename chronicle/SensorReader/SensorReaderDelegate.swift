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
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        devices.forEach { device in
            let request = SRFetchRequest()
            request.device = device
            request.to = SRAbsoluteTime.current()
            request.from = Utils.getLastFetch(
                device: SensorReaderDevice(device: device),
                sensorName: Sensor.getSensorName(sensor: reader.sensor)
            )
            logger.info("fetching data for \(reader.sensor.rawValue) from \(request.from.rawValue) to \(request.to.rawValue)")
            reader.fetch(request)
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
        logger.error("unable to fetch devices for sensor: \(reader.sensor.rawValue)")
    }
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        logger.info("completed fetch request for \(reader.sensor.rawValue)")
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        
        let sensor = reader.sensor
        let timestamp = result.timestamp
        let sample = result.sample
        let device = fetchRequest.device
        
        logger.info("successfully fetched sample from \(sensor.rawValue)")
        
        var sensorDataProperties: SensorDataProperties?

        switch sensor {
        case .phoneUsageReport:
            sensorDataProperties = SensorDataConverter.getPhoneUsageData(sample: sample as! SRPhoneUsageReport, timestamp: timestamp, device: device)
        case .keyboardMetrics:
            sensorDataProperties = SensorDataConverter.getKeyboardMetricsData(sample: sample as! SRKeyboardMetrics, timestamp: timestamp, device: device)
        case .deviceUsageReport:
            sensorDataProperties = SensorDataConverter.getDeviceUsageData(sample: sample as! SRDeviceUsageReport, timestamp: timestamp, device: device)
        case .messagesUsageReport:
            sensorDataProperties = SensorDataConverter.getMessagesData(sample: sample as! SRMessagesUsageReport, timestamp: timestamp, device: device)
        default:
            print("sensor \(sensor) is not supported")
        }
        
        guard let sensorDataProperties = sensorDataProperties else {
            return true
        }
        
        if (sensorDataProperties.isValidSample) {
            appDelegate.importIntoCoreData(data: sensorDataProperties)
        }
        
        // save last fetch
        Utils.saveLastFetch(
            device: SensorReaderDevice(device: fetchRequest.device),
            sensorName: Sensor.getSensorName(sensor: sensor),
            lastFetchValue: fetchRequest.to.toCFAbsoluteTime()
        )
        return true
    }
}
