//
//  Utils.swift
//  Utils
//
//  Created by Alfonce Nzioka on 11/3/21.
//

import Foundation
import SensorKit

struct Utils {
    // converts a [String: String] dictionary to [FullQualified: String]
    static func toFqnUUIDMap(_ input: [String: String]) -> [FullQualifiedName: UUID] {
        var result: [FullQualifiedName: UUID] = [:]
        
        for (key, val) in input {
            if let fqn = FullQualifiedName.fromString(key), let uuid = UUID.init(uuidString: val) {
                result[fqn] = uuid
            }
        }
        
        return result
    }
    
    static func getLastFetch(device: SensorReaderDevice, sensorName: String) -> SRAbsoluteTime {
        let data = UserDefaults.standard.object(forKey: UserSettingsKeys.lastFetch) as? [String: [Int: Double]] ?? [:]
        
        if let valuesBySensor = data[sensorName], let value = valuesBySensor[device.hashValue] {
            
            return SRAbsoluteTime.fromCFAbsoluteTime(_cf: value)
        }
        
        // this refers to 1 Jan 2001 00:00:01 GMT.
        // ref: https://developer.apple.com/documentation/corefoundation/cfabsolutetime
        let absoluteRefTime: CFTimeInterval = 1
        return SRAbsoluteTime.fromCFAbsoluteTime(_cf: absoluteRefTime)
    }
    
    static func saveLastFetch(device: SensorReaderDevice, sensorName: String, lastFetchValue: Double) {
        var data = UserDefaults.standard.object(forKey: UserSettingsKeys.lastFetch) as? [String: [Int: Double]] ?? [:]
        if var valuesBySensor = data[sensorName] {
            valuesBySensor[device.hashValue] = lastFetchValue
            data[sensorName] = valuesBySensor
        }
        
        UserDefaults.standard.set(data, forKey: UserSettingsKeys.lastFetch)
    }
}
