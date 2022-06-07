//
//  EnrollmentUtils.swift
//  EnrollmentUtils
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation
import UIKit


/// Utility functions to handle device enrollment
struct EnrollmentUtils {
    static var defaults = UserDefaults.standard

    // returns information about the device: https://developer.apple.com/documentation/uikit/uidevice
    static func getDeviceInformation() async -> IOSDevice {
        let device = await UIDevice.current
        
        let model = await device.model
        let localizedModel = await device.localizedModel
        let version = await device.systemVersion
        let name = await device.name
        let deviceId = await device.identifierForVendor?.uuidString // same for apps from the same vendor running on the same device: https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor
        let systemName = await device.systemName
        
        return IOSDevice(model: model, localizedModel: localizedModel, version: version, deviceId: deviceId, name: name, systemName: systemName)
    }
    
    static func setUserDefaults(studyId: String, participantId: String) {
        let defaults = UserDefaults.standard
        defaults.set(studyId, forKey: "studyId")
        defaults.set(participantId, forKey: "participantId")
    }
}

