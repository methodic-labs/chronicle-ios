//
//  EnrollmentError.swift
//  EnrollmentError
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

enum EnrollmentError {
    case serverError(description: String)
    case invalidUrl
    case invalidDeviceId
    case invalidInput(invalidParticipantId: Bool = false, invalidStudyId: Bool = false, invalidOrganizationId: Bool = false)
    case encodingError // when JSONEncoder(Enrollment).encode fails
}
