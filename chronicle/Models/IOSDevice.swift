//
//  IOSDevice.swift
//  IOSDevice
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

// information about the device
// ref: https://developer.apple.com/documentation/uikit/uidevice
struct IOSDevice :Codable {
    var model: String
    var version: String
    var deviceId: String?
    var name: String
    var systemName: String
    
    /// enrollDevice endpoint exptects @class property in object when deserializing
    var className: String = String(describing: IOSDevice.self)
    
    init(model: String, version: String, deviceId: String?, name: String, systemName: String) {
        self.model = model
        self.version = version
        self.deviceId = deviceId
        self.name = name
        self.systemName = systemName
    }
    
    enum CodingKeys: String, CodingKey {
        case model
        case version
        case name
        case systemName
        case deviceId
        case className = "@class"
    }
}
