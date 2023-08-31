//
//  ChronicleTests.swift
//  ChronicleTests
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import XCTest
@testable import chronicle

class ChronicleTests: XCTestCase {
    
    let studyId = UUID().uuidString
    let deviceId = UUID().uuidString
    let participantId = "1001"
    
    func testEnrollmentUrl() {
        let enrollment = Enrollment(participantId: participantId, studyId: studyId)
        let url = ApiUtils.getEnrollURL(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNotNil(url, "should not be nil")
        XCTAssertEqual(
            url?.path,
            "/chronicle/v3/study/\(studyId)/participant/\(participantId)/\(deviceId)/enroll"
        )
        XCTAssertEqual(url?.host!, "api.getmethodic.com")
        XCTAssertEqual(url?.scheme, "https")
    }
    
    func testInvalidParticipantId() {
        let enrollment = Enrollment(participantId: "", studyId: studyId)
        let url = ApiUtils.getEnrollURL(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(url, "Empty participantId should result in nil")
    }
    
    func testInvalidStudyId() {
        let invalidStudyId = "invalid"
        let enrollment = Enrollment(participantId: participantId, studyId: invalidStudyId)
        let urlComponents = ApiUtils.getEnrollURL(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(urlComponents, "\(invalidStudyId) should result in nil")
    }

    
    func testUserDefaultsAssignment() {

        EnrollmentUtils.setUserDefaults(studyId: studyId, participantId: participantId)
        let defaults = UserDefaults.standard
        XCTAssertEqual(defaults.string(forKey: "studyId"), studyId)
        XCTAssertEqual(defaults.string(forKey: "participantId"), participantId)
    }
}
