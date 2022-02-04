//
//  Utils.swift
//  Utils
//
//  Created by Alfonce Nzioka on 11/3/21.
//

import Foundation
import SensorKit
import OSLog

struct Utils {
    
    private static var logger = Logger(subsystem: "com.openlattice.chronicle", category: "Utils")
    
    static func getLastFetch(device: SensorReaderDevice, sensor: Sensor) -> SRAbsoluteTime {
        
        let data = UserDefaults.standard.object(forKey: UserSettingsKeys.lastFetch) as? [String: [String: Double]] ?? [:]
        
//        if let valuesBySensor = data[sensorName], let value = valuesBySensor[device.systemName] {
//            return SRAbsoluteTime.fromCFAbsoluteTime(_cf: value)
//        }
        
        // this refers to 1 Jan 2001 00:00:01 GMT.
        // ref: https://developer.apple.com/documentation/corefoundation/cfabsolutetime
        let absoluteRefTime: CFTimeInterval = 1
        return SRAbsoluteTime.fromCFAbsoluteTime(_cf: absoluteRefTime)
    }
    
    static func saveLastFetch(device: SensorReaderDevice, sensor: Sensor, lastFetchValue: Double) {
        
        var data = UserDefaults.standard.object(forKey: UserSettingsKeys.lastFetch) as? [String: [String: Double]] ?? [:]
        
        var valuesBySensor = data[sensor.rawValue] ?? [:]
        valuesBySensor[device.systemName] = lastFetchValue
        data[sensor.rawValue] = valuesBySensor
        
        UserDefaults.standard.set(data, forKey: UserSettingsKeys.lastFetch)
    }

    
    // saves lastFetch = current date the very first time authorization to use sensor is granted
    
    static func saveInitialLastFetch(sensor: Sensor) {
        var dict = UserDefaults.standard.object(forKey: UserSettingsKeys.lastFetch) as? [String: [String: Double]] ?? [:]
        
        let lastFetch = Date()
        var savedValues = dict[sensor.rawValue] ?? [:]
        
        if (savedValues.isEmpty) {
            savedValues[SensorReaderDevice.iOSModel] = lastFetch.timeIntervalSinceNow
            
            if (sensor == Sensor.deviceUsage ) {
                savedValues[SensorReaderDevice.watchOSModel] = lastFetch.timeIntervalSinceNow
            }
            dict[sensor.rawValue] = savedValues
            
            logger.info("saving initial lastFetch value for \(sensor.rawValue) sensor: \(savedValues)")
        }
        
        UserDefaults.standard.set(dict, forKey: UserSettingsKeys.lastFetch)
    }
}
