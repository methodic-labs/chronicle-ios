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
    
    // returns an optional EnrollmentError if any of the input is invalid
    static func validateEnrollmentDetails (enrollment: Enrollment, withOrgId: Bool) -> EnrollmentError? {
        let invalidParticipantId = enrollment.participantId.isEmpty
        let invalidStudyId = UUID.init(uuidString: enrollment.studyId) == nil
        let invalidOrgId = withOrgId && UUID.init(uuidString: enrollment.organizationId) == nil
        
        if (invalidParticipantId || invalidStudyId || invalidOrgId ) {
            return EnrollmentError.invalidInput(
                invalidParticipantId: invalidParticipantId,
                invalidStudyId: invalidStudyId,
                invalidOrganizationId: invalidOrgId)
        }
        
        return nil
    }
    
    // returns information about the device: https://developer.apple.com/documentation/uikit/uidevice
    static func getDeviceInformation() async -> Device {
        let device = await UIDevice.current
        
        let model = await device.model
        let version = await device.systemVersion
        let name = await device.name
        let deviceId = await device.identifierForVendor?.uuidString // same for apps from the same vendor running on the same device: https://developer.apple.com/documentation/uikit/uidevice/1620059-identifierforvendor
        let systemName = await device.systemName
        
        return Device(model: model, version: version, deviceId: deviceId, name: name, systemName: systemName)
    }
}

