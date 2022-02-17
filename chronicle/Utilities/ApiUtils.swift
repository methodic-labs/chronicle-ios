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
    static let sensors = "sensors"
    static let upload = "upload"
    static let settings = "settings"
    static let ios = "ios"

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
        
        let studyId = enrollment.studyId!
        let participantId = enrollment.participantId
        

        // STUDY_ID_PATH + PARTICIPANT_PATH + PARTICIPANT_ID_PATH + IOS_PATH + SOURCE_DEVICE_ID_PATH
        components.scheme = scheme
        components.host = host
        components.path = "\(studyApiBase)/\(studyId)/\(participant)/\(participantId)/\(ios)/\(deviceId)"

        return components
    }
    
    static func getStudySensorsURl(studyId: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "\(studyApiBase)/\(studyId)/\(settings)/\(sensors)"
        
        return components.url
    }
}
