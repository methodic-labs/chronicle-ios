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
        static var host = "api.openlattice.com"
        static let v2Base = "/chronicle/v2"
        static let base = "/chronicle"
        
        // path constants
        static let enrollPath = "/enroll"
        static let studyPath = "/study"
    }
    
    // returns an optional URLComponent with orgId in the path
    static func makeEnrollDeviceUrlComponents (enrollment: Enrollment, deviceId: String) -> URLComponents? {
        guard enrollment.isValid else {
            return nil
        }
        
        guard !deviceId.isEmpty else {
            return nil
        }
        
        var components = URLComponents()
        
        components.scheme = ChronicleApi.scheme
        components.host = ChronicleApi.host
        components.path = "\(ChronicleApi.v2Base)/\(enrollment.organizationId!)/\(enrollment.studyId!)/\(enrollment.participantId)/\(deviceId)\(ChronicleApi.enrollPath)"
        
        // debug: set components.scheme = 'http', components.host = [local server ip] , components.port = 8090
        // expected path: /chronicle/v2 + ORGANIZATION_ID_PATH + STUDY_ID_PATH + PARTICIPANT_ID_PATH + DATASOURCE_ID_PATH + ENROLL_PATH
        return components
    }
    
    // returns an optional URLComponent for legacy enrollment
    static func makeEnrollDeviceComponentsWithoutOrg(enrollment: Enrollment, deviceId: String) -> URLComponents? {
        
        guard enrollment.isValid else {
            return nil
        }
        
        guard !deviceId.isEmpty else {
            return nil
        }
        
        var components = URLComponents()
        components.scheme = ChronicleApi.scheme
        components.host = ChronicleApi.host
        components.path = "\(ChronicleApi.base)\(ChronicleApi.studyPath)/\(enrollment.studyId!)/\(enrollment.participantId)/\(deviceId)"
        // debug: set components.scheme = 'http', components.host = [local server ip] , components.port = 8090
        
        // expected path: /chronicle/study + STUDY_ID_PATH + PARTICIPANT_ID_PATH + DATASOURCE_ID_PATH
        return components
    }
}
