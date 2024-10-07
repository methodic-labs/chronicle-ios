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
    private let twentyFourHoursInSeconds: SRAbsoluteTime = SRAbsoluteTime.init(24.0*60*60)
    static var shared = SensorReaderDelegate()
    static var fetching = DispatchSemaphore(value: 1)
    
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
        if( hoursElapsedSinceEnrollment < 24) {
            return
        }
        
        var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
        eventLogParams.merge(["devices": devices.description, "hoursElapsedSinceEnrollment" : String(hoursElapsedSinceEnrollment)]) { (current, _) in current }
        
        Analytics.logEvent(FirebaseAnalyticsEvent.didFetchSensorDevices.rawValue, parameters: eventLogParams)
        
        
        devices.forEach { device in
            let request = SRFetchRequest()
            
            request.device = device
            
            let sevenDaysAgo = request.to.rawValue - 7*twentyFourHoursInSeconds.rawValue

            let lastFetch = Utils.getLastFetch(
                device: SensorReaderDevice(device: device),
                sensor: Sensor.getSensor(sensor: reader.sensor)
            ) ?? SRAbsoluteTime.init(max(sevenDaysAgo, enrollmentAbsoluteTime.rawValue))
        
            
            request.from = lastFetch
            //Only request data that is older than 24 hours.
            request.to = SRAbsoluteTime.init(SRAbsoluteTime.current().rawValue - twentyFourHoursInSeconds.rawValue)
            // Let's get ISO dates for readable logs.

            let startDate = Date(timeIntervalSinceReferenceDate: request.from.toCFAbsoluteTime())
            let endDate  = Date(timeIntervalSinceReferenceDate: request.to.toCFAbsoluteTime())
            
            logger.info("fetching data for \(reader.sensor.rawValue) -  start: \(startDate.description), end: \(endDate.description)")
            reader.fetch(request)
            
            var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
            eventLogParams.merge(["device": device.description, "startDate": startDate.toISOFormat(), "endDate": endDate.toISOFormat(), "hoursElapsedSinceEnrollment" : String(hoursElapsedSinceEnrollment)]) { (current, _) in current }
            
            Analytics.logEvent(FirebaseAnalyticsEvent.didFetchSensorDevices.rawValue, parameters: eventLogParams)
            
            let timestampIso = Date(timeIntervalSinceReferenceDate: SRAbsoluteTime.current().toCFAbsoluteTime()).toISOFormat()
            UserDefaults.standard.set(timestampIso, forKey:UserSettingsKeys.lastFetchSubmitted)
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
        var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
               eventLogParams.merge(["device": reader.sensor.rawValue, "description" : reader.description, "error": error.localizedDescription]) { (current, _) in current }
               Analytics.logEvent(FirebaseAnalyticsEvent.fetchSensorSampleFailedUnknownType.rawValue, parameters: eventLogParams)
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
        let lastReport = SRAbsoluteTime.current();
        let lastReportIso = Date(timeIntervalSinceReferenceDate: lastReport.toCFAbsoluteTime()).toISOFormat()
        let timestampIso = Date(timeIntervalSinceReferenceDate: timestamp.toCFAbsoluteTime()).toISOFormat()
        
        UserDefaults.standard.set(lastReportIso, forKey:UserSettingsKeys.lastReport)
        
        var eventLogParams = [
            "sensor": sensor.rawValue,
            "timestamp": timestampIso,
            "reportTime": lastReportIso
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
            Analytics.logEvent(FirebaseAnalyticsEvent.fetchSensorSampleFailedUnknownType.rawValue, parameters: eventLogParams)
            return true
        }

        let lastFetch = Utils.getLastFetch(
            device: SensorReaderDevice(device: fetchRequest.device),
            sensor: Sensor.getSensor(sensor: reader.sensor)
        )
        
        let latestFetch = max(lastFetch?.rawValue ?? 0.0, timestamp.rawValue )
        if (sensorDataProperties.isValidSample) {
            guard let context = PersistenceController.shared.newBackgroundContext() else {
                
                //Don't save last fetch if data was not imported into core data.
//                Utils.saveLastFetch(
//                    device: SensorReaderDevice(device: fetchRequest.device),
//                    sensor: Sensor.getSensor(sensor: reader.sensor),
//                    lastFetchValue: latestFetch
//                )
                Analytics.logEvent(FirebaseAnalyticsEvent.fetchSensorSampleFailedPersistenceController.rawValue, parameters: eventLogParams)
                return true
            }
            let operation = ImportIntoCoreDataOperation(context: context, data: sensorDataProperties)
            operation.start()
            operation.waitUntilFinished()
            // Save the last fetch after data is fully imported successfully.
            Utils.saveLastFetch(
                device: SensorReaderDevice(device: fetchRequest.device),
                sensor: Sensor.getSensor(sensor: reader.sensor),
                lastFetchValue: latestFetch
            )
        }
        
  
        UserDefaults.standard.set(
            Date(timeIntervalSinceReferenceDate: SRAbsoluteTime(latestFetch).toCFAbsoluteTime()).toISOFormat(),
            forKey:UserSettingsKeys.lastRecordedDate
        )
        
        return true
    }
}
