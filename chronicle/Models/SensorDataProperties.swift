//
//  SensorDataProperties.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/28/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit

// A struct encapsulating the properties of a SensorData
struct SensorDataProperties {
    let sensor: Sensor
    var duration: Double // duration that the sample spans
    let writeTimestamp: Date // when sensor sample was recorded
    let timezone: String = TimeZone.current.identifier
    let data: Data?
    let device: Data?
    
    var isValidSample: Bool {
        return data != nil
    }
    
    init(sensor: Sensor, duration: TimeInterval, writeTimeStamp: SRAbsoluteTime, data: Data?, device: SensorReaderDevice) {
        
        self.sensor = sensor
        self.duration = duration
        self.data = data
        self.device = try? JSONEncoder().encode(device)
        
        // specific point in time relative to the absolute reference date of 1 Jan 2001 00:00:00 GMT.
        let abs = writeTimeStamp.toCFAbsoluteTime()
        
        // Date relative to 00:00:00 UTC on 1 January 2001 by a given number of seconds.
        self.writeTimestamp = Date(timeIntervalSinceReferenceDate: abs)
        
    }
    
    func toString() -> String {
        return "SensorDataProperties:{sensor: \(sensor), writeTimeStamp: \(writeTimestamp), data: \(String(data: data ?? Data.init(), encoding: .utf8) ?? "")"
    }
}


