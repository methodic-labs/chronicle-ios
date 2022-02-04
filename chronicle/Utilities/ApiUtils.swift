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
    static let enroll = "enroll"
    static let study = "study"
    static let participant = "participant"
    static let edmPath = "edm"

    // returns an optional URLComponent with orgId in the path
    static func makeEnrollDeviceUrlComponents (enrollment: Enrollment, deviceId: String) -> URLComponents? {
        guard enrollment.isValid else {
            return nil
        }

        guard !deviceId.isEmpty else {
            return nil
        }

        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "\(base)/\(study)/\(enrollment.studyId!)/\(participant)/\(enrollment.participantId)/\(deviceId)/\(enroll)"

        // debug: set components.scheme = 'http', components.host = [local server ip] , components.port = 8090
        // expected path: /chronicle/v2 + ORGANIZATION_ID_PATH + STUDY_ID_PATH + PARTICIPANT_ID_PATH + DATASOURCE_ID_PATH + ENROLL_PATH
        return components
    }

    static func createSensorDataUploadURLComponents(enrollment: Enrollment, deviceId: String) -> URLComponents? {
        var components = URLComponents()

        guard enrollment.isValid else {
            return nil
        }
        guard !deviceId.isEmpty else {
            return nil
        }

        components.scheme = scheme
        components.host = host
        components.path = "/chronicle/v2/\(enrollment.organizationId!)/\(enrollment.studyId!)/\(enrollment.participantId)/\(deviceId)/upload/ios"

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
