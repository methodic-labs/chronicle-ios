//
//  SensorDataProperties.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/28/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import Foundation
import SensorKit

// A struct encapsulating the properties of a SensorData
struct SensorDataProperties {
    let id: UUID = UUID.init()
    let sensor: Sensor?
    var duration: Double // duration that the sample spans
    let writeTimestamp: Date // when sensor sample was recorded
    let startDate: Date
    let endDate: Date
    let timezone: String = TimeZone.current.identifier
    let data: Data?
    let device: Data?
    
    var isValidSample: Bool {
        return data != nil && sensor != nil
    }
    
    init(sensor: Sensor?, duration: TimeInterval, writeTimeStamp: SRAbsoluteTime, from: SRAbsoluteTime, to: SRAbsoluteTime, data: Data?, device: Data?) {
        
        self.sensor = sensor
        self.duration = duration
        self.data = data
        self.device = device
        
        // Date relative to 00:00:00 UTC on 1 January 2001 by a given number of seconds.
        self.writeTimestamp = Date(timeIntervalSinceReferenceDate: writeTimeStamp.toCFAbsoluteTime())
        self.endDate = Date(timeIntervalSinceReferenceDate: to.toCFAbsoluteTime())
        self.startDate = Date(timeIntervalSinceReferenceDate: from.toCFAbsoluteTime())
    }
    
    func toString() -> String {
        return "SensorDataProperties:{sensor: \(String(describing: sensor)), writeTimeStamp: \(writeTimestamp), data: \(String(data: data ?? Data.init(), encoding: .utf8) ?? "")"
    }
}


