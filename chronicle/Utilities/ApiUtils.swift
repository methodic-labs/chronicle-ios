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
    static let studyApiBase = "/chronicle/v3/study"
    
    // path constants
    static let enroll = "enroll"
    static let iosSensor = "ios-sensor"
    static let study = "study"
    static let participant = "participant"
    static let sensor = "sensor"
    static let upload = "upload"

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
        components.path = "\(studyApiBase)/\(enrollment.studyId!)/\(participant)/\(enrollment.participantId)/\(deviceId)/\(enroll)"

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
        components.path = "\(studyApiBase)/\(enrollment.studyId!)/\(enrollment.participantId)/\(deviceId)/\(upload)/\(sensor)"

        return components
    }
}
