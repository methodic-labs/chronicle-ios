//
//  SensorReaderDevice.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 2/1/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit

// this class models SRDevice that provides sample data
// ref: (https://developer.apple.com/documentation/sensorkit/srdevice)
struct SensorReaderDevice: Codable {
    let model: String
    let name: String
    let systemName: String
    let systemVersion: String
    
    init(device: SRDevice) {
        self.model = device.model
        self.name = device.name
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
    }
    
    init(model: String, name: String, systemName: String, systemVersion: String) {
        self.model = model
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.name  = name
    }
}

extension SensorReaderDevice {
    // models supported by SRDevice class
    static var iOSModel = "iOS"
    static var watchOSModel = "watchOS"
}
