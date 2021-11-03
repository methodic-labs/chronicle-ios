//
//  ApiUtils.swift
//  ApiUtils
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Utility functions for API calls
struct ApiUtils {
    
    static let scheme = "https"
    static var host = "api.openlattice.com"
    static let v2Base = "/chronicle/v2"
    static let base = "/chronicle"
    
    // path constants
    static let enrollPath = "enroll"
    static let studyPath = "study"
    static let edmPath = "edm"
    
    // returns an optional URLComponent with orgId in the path
    static func makeEnrollDeviceComponentsWithOrg (enrollment: Enrollment, deviceId: String) -> URLComponents? {
        guard EnrollmentUtils.validateEnrollmentDetails(enrollment: enrollment, withOrgId: true) else {
            return nil
        }
        
        guard !deviceId.isEmpty else {
            return nil
        }
        
        var components = URLComponents()
        
        components.scheme = scheme
        components.host = host
        components.path = "\(v2Base)/\(enrollment.organizationId)/\(enrollment.studyId)/\(enrollment.participantId)/\(deviceId)/\(enrollPath)"
        
        // debug: set components.scheme = 'http', components.host = [local server ip] , components.port = 8090
        // expected path: /chronicle/v2 + ORGANIZATION_ID_PATH + STUDY_ID_PATH + PARTICIPANT_ID_PATH + DATASOURCE_ID_PATH + ENROLL_PATH
        return components
    }
    
    // returns an optional URLComponent for legacy enrollment
    static func makeEnrollDeviceComponentsWithoutOrg(enrollment: Enrollment, deviceId: String) -> URLComponents? {
        
        guard EnrollmentUtils.validateEnrollmentDetails(enrollment: enrollment, withOrgId: false) else {
            return nil
        }
        
        guard !deviceId.isEmpty else {
            return nil
        }
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host

        components.path = "\(base)/\(studyPath)/\(enrollment.studyId)/\(enrollment.participantId)/\(deviceId)"
        // debug: set components.scheme = 'http', components.host = [local server ip] , components.port = 8090
        
        // expected path: /chronicle/study + STUDY_ID_PATH + PARTICIPANT_ID_PATH + DATASOURCE_ID_PATH
        return components
    }
    
    static func getPropertyTypeIdsUrlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "\(v2Base)/\(edmPath)"
        
        return components
    }
}
