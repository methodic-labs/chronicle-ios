//
//  ApiUtils.swift
//  ApiUtils
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Utility functions for API calls
struct ApiUtils {
    
    struct ChronicleApi {
        
        static let scheme = "https"
        static let host = "api.openlattice.com"
        static let v2Base = "/chronicle/v2"
        static let base = "/chronicle"
        
        // path constants
        static let enrollPath = "/enroll"
        static let studyPath = "/study"
    }
    
    // returns an optional URLComponent with orgId in the path
    static func makeEnrollDeviceComponentsWithOrg (enrollment: Enrollment, deviceId: String) -> URLComponents? {
        guard EnrollmentUtils.validateEnrollmentDetails(enrollment: enrollment, withOrgId: true) == nil else {
            return nil
        }
        
        guard !deviceId.isEmpty else {
            return nil
        }
        
        var components = URLComponents()

        components.scheme = ChronicleApi.scheme
        components.host = ChronicleApi.host
        components.path = "\(ChronicleApi.v2Base)/\(enrollment.organizationId)/\(enrollment.studyId)/\(enrollment.participantId)/\(deviceId)\(ChronicleApi.enrollPath)"
        
        // expected path: /chronicle/v2 + ORGANIZATION_ID_PATH + STUDY_ID_PATH + PARTICIPANT_ID_PATH + DATASOURCE_ID_PATH + ENROLL_PATH
        return components
    }
    
    // returns an optional URLComponent for legacy enrollment
    static func makeEnrollDeviceComponentsWithoutOrg(enrollment: Enrollment, deviceId: String) -> URLComponents? {
 
        guard EnrollmentUtils.validateEnrollmentDetails(enrollment: enrollment, withOrgId: false) == nil else {
            return nil
        }
        
        guard !deviceId.isEmpty else {
            return nil
        }
        
        var components = URLComponents()
        components.scheme = ChronicleApi.scheme
        components.host = ChronicleApi.host
        components.path = "\(ChronicleApi.base)\(ChronicleApi.studyPath)/\(enrollment.studyId)/\(enrollment.participantId)/\(deviceId)"
        
        // expected path: /chronicle/study + STUDY_ID_PATH + PARTICIPANT_ID_PATH + DATASOURCE_ID_PATH
        return components
    }
}
