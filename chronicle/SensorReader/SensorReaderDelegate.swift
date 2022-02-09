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
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorReader")
    
    static var shared = SensorReaderDelegate()
    
    static var availableSensors: Set<SRSensor> {
        return [
            .deviceUsageReport,
            .messagesUsageReport,
            .phoneUsageReport,
            .keyboardMetrics
        ]
    }
    
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
                sensor: Sensor.getSensor(sensor: reader.sensor)
            )
            let startDate = Date(timeIntervalSinceReferenceDate: request.from.toCFAbsoluteTime())
            let endDate  = Date(timeIntervalSinceReferenceDate: request.to.toCFAbsoluteTime())
            
            logger.info("fetching data for \(reader.sensor.rawValue) -  start: \(startDate.description), end: \(endDate.description)")
            reader.fetch(request)
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
        logger.error("unable to fetch devices for sensor: \(reader.sensor.rawValue)")
    }
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        logger.info("successfully fetched sample from \(reader.sensor.rawValue)")
    }
    
    // NOTE: this will be invoked multiple times if the request has multiple samples
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        
        let sensor = reader.sensor
        let timestamp = result.timestamp
        let sample = result.sample
                
        var sensorDataProperties: SensorDataProperties

        switch sensor {
        case .phoneUsageReport:
            sensorDataProperties = SensorDataConverter.getPhoneUsageData(
                sample: sample as! SRPhoneUsageReport,
                timestamp: timestamp,
                request: fetchRequest
            )
        case .keyboardMetrics:
            sensorDataProperties = SensorDataConverter.getKeyboardMetricsData(
                sample: sample as! SRKeyboardMetrics,
                timestamp: timestamp,
                request: fetchRequest
            )
        case .deviceUsageReport:
            sensorDataProperties = SensorDataConverter.getDeviceUsageData(
                sample: sample as! SRDeviceUsageReport,
                timestamp: timestamp,
                request: fetchRequest
            )
        case .messagesUsageReport:
            sensorDataProperties = SensorDataConverter.getMessagesData(
                sample: sample as! SRMessagesUsageReport,
                timestamp: timestamp,
                request: fetchRequest
            )
        default:
            logger.error("sensor \(sensor.rawValue) is not supported")
            return false
        }
        
        if (sensorDataProperties.isValidSample) {
            guard let context = PersistenceController.shared.newBackgroundContext() else {
                Utils.saveLastFetch(
                    device: SensorReaderDevice(device: fetchRequest.device),
                    sensor: Sensor.getSensor(sensor: reader.sensor),
                    lastFetchValue: fetchRequest.to.toCFAbsoluteTime()
                )
                return false
            }
            let operation = ImportIntoCoreDataOperation(context: context, data: sensorDataProperties)
            operation.start()
        }
        
        // save last fetch
        Utils.saveLastFetch(
            device: SensorReaderDevice(device: fetchRequest.device),
            sensor: Sensor.getSensor(sensor: reader.sensor),
            lastFetchValue: fetchRequest.to.toCFAbsoluteTime()
        )
        
        return true
    }
}
