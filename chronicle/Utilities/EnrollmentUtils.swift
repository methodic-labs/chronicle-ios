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
    
    // returns true if participantId, organizationId and studyId are valid values
    static func validateEnrollmentDetails (enrollment: Enrollment, withOrgId: Bool) -> Bool {
        let invalidParticipantId = enrollment.participantId.isEmpty
        let invalidStudyId = UUID.init(uuidString: enrollment.studyId) == nil
        let invalidOrgId = withOrgId && UUID.init(uuidString: enrollment.organizationId) == nil
        
        return !(invalidParticipantId || invalidStudyId || invalidOrgId)
    }
    
    // returns information about the device: https://developer.apple.com/documentation/uikit/uidevice
    static func getDeviceInformation() async -> IOSDevice {
        let device = await UIDevice.current
        
        let model = await device.model
        let version = await device.systemVersion
        let name = await device.name
        let deviceId = await device.identifierForVendor?.uuidString // same for apps from the same vendor running on the same device: https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor
        let systemName = await device.systemName
        
        return IOSDevice(model: model, version: version, deviceId: deviceId, name: name, systemName: systemName)
    }
}

