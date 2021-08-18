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
    var localizedModel: String
    
    /// fully qualified java class name required when deserializing object
    var className = "com.openlattice.chronicle.sources.IOSDevice"
    
    init(model: String, localizedModel: String, version: String, deviceId: String?, name: String, systemName: String) {
        self.model = model
        self.localizedModel = localizedModel
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
        case localizedModel
        case className = "@class" /// required by Jackson deserializer
    }
}
