//
//  SensorReaderDelegate.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import Foundation
import SensorKit
import OSLog
import FirebaseAnalytics

/**
  This class responds to sensor-related events
 */
class SensorReaderDelegate: NSObject, SRSensorReaderDelegate {
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorReader")
    
    static var shared = SensorReaderDelegate()
    
    static var availableSensors: Set<SRSensor> {
        let savedValues = UserDefaults.standard.object(forKey: UserSettingsKeys.sensors) as? [String] ?? []
        if (savedValues.isEmpty) {
            return []
        }
        
        let sensors = savedValues.map { Sensor.init(rawValue: $0) }.compactMap { $0 }
        
        return Set(sensors.map { Sensor.getSRSensor(sensor: $0)}.compactMap { $0 })
        
    }
    
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        logger.info("started recording \(reader.sensor.rawValue)")
    }
    
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        logger.info("stopped recording \(reader.sensor.rawValue)")
    }
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        let enrolledDate = UserDefaults.standard.object(forKey: UserSettingsKeys.enrolledDate) as? Date ?? Date()
        
        let hoursElapsedSinceEnrollment = Calendar.current.dateComponents([.hour], from: enrolledDate, to: Date()).hour ?? 0
        let secondsSinceEnrollment = Calendar.current.dateComponents([.second], from: enrolledDate, to: Date()).second ?? 0
        let enrollmentAbsoluteTime = SRAbsoluteTime.init(SRAbsoluteTime.current().rawValue - Double(secondsSinceEnrollment))
      
        //Don't submit any fetch requests until at least 24 hours have passed since enrollment
        //as SensorKit holds values for 24 hours to allow user to delete them.
//        if( hoursElapsedSinceEnrollment < 24) {
//            return
//        }
        
        var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
        eventLogParams.merge(["devices": devices.description, "hoursElapsedSinceEnrollment" : String(hoursElapsedSinceEnrollment)]) { (current, _) in current }
        
        Analytics.logEvent(FirebaseAnalyticsEvent.didFetchSensorDevices.rawValue, parameters: eventLogParams)
        
        let twentyFourHoursInSeconds: SRAbsoluteTime = SRAbsoluteTime.init(24.0*60*60)
        devices.forEach { device in
            let request = SRFetchRequest()
            request.device = device
            //Should only request data that is older than 24 hours.
            //Since last fetch gets set to request.to, it will always be at leat 24 hours in the past next
            //time this code runs. So you will always have a window, even if it is small, of data to pull.
            //request.to = SRAbsoluteTime.init(SRAbsoluteTime.current().rawValue - twentyFourHoursInSeconds.rawValue)
            request.to = SRAbsoluteTime.current()
            
            //let lastFetch = Utils.getLastFetch(
            //    device: SensorReaderDevice(device: device),
            //    sensor: Sensor.getSensor(sensor: reader.sensor)
            //)
            //
            //guard let lastFetch = lastFetch else {
            //    return
            //}

            let nineDaysAgo = request.to.rawValue - 9*twentyFourHoursInSeconds.rawValue
            
            //Get 1 week ago as long as it is after enrollment, but before last fetch.
            request.from = SRAbsoluteTime.init(max(nineDaysAgo, enrollmentAbsoluteTime.rawValue));
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
        logger.info("fetch completed for \(reader.sensor.rawValue)")
    }
    
    // NOTE: this will be invoked multiple times if the request has multiple samples
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        let sensor = reader.sensor
        let timestamp = result.timestamp
        let sample = result.sample
        let timestampIso = Date(timeIntervalSinceReferenceDate: timestamp.toCFAbsoluteTime()).toISOFormat()
        
        var eventLogParams = [
            "sensor": sensor.rawValue,
            "timestamp": timestampIso
        ]
        
        let enrollment = Enrollment.getCurrentEnrollment()
        eventLogParams.merge(enrollment.toDict()) { (_, new) in new }
        Analytics.logEvent(FirebaseAnalyticsEvent.didFetchSensorSample.rawValue, parameters: eventLogParams)
                
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

        let lastFetch = Utils.getLastFetch(
            device: SensorReaderDevice(device: fetchRequest.device),
            sensor: Sensor.getSensor(sensor: reader.sensor))
        
        let latestFetch = max(lastFetch?.rawValue ?? 0.0, timestamp.rawValue )
        if (sensorDataProperties.isValidSample) {
            guard let context = PersistenceController.shared.newBackgroundContext() else {
                Utils.saveLastFetch(
                    device: SensorReaderDevice(device: fetchRequest.device),
                    sensor: Sensor.getSensor(sensor: reader.sensor),
                    lastFetchValue: latestFetch
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
            lastFetchValue: latestFetch
        )
        UserDefaults.standard.set(Date(timeIntervalSinceReferenceDate: SRAbsoluteTime(latestFetch).toCFAbsoluteTime()).toISOFormat(), forKey:UserSettingsKeys.lastRecordedDate)
        return true
    }
}
