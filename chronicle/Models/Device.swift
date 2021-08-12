//
//  Device.swift
//  Device
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

// information about the device
// ref: https://developer.apple.com/documentation/uikit/uidevice
struct Device :Codable {
    var model: String
    var version: String
    var deviceId: String?
    var name: String
    var systemName: String
    
    init(model: String, version: String, deviceId: String?, name: String, systemName: String) {
        self.model = model
        self.version = version
        self.deviceId = deviceId
        self.name = name
        self.systemName = systemName
    }
}
