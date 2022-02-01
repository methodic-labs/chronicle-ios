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
    let organizationId = UUID().uuidString
    let deviceId = UUID().uuidString
    let participantId = "1001"
    
    func testEnrollmentUrlWithOrg() {
        let enrollment = Enrollment(participantId: participantId, studyId: studyId, organizationId: organizationId)
        let urlComponents = ApiUtils.makeEnrollDeviceUrlComponents(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNotNil(urlComponents, "should not be nil")
        XCTAssertEqual(
            urlComponents?.path,
            "/chronicle/v2/\(organizationId)/\(studyId)/\(participantId)/\(deviceId)/enroll"
        )
        XCTAssertEqual(urlComponents?.host, "api.openlattice.com")
        XCTAssertEqual(urlComponents?.scheme, "https")
    }
    
    func testInvalidParticipantId() {
        let enrollment = Enrollment(participantId: "", studyId: studyId, organizationId: organizationId)
        let urlComponents = ApiUtils.makeEnrollDeviceUrlComponents(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(urlComponents, "Empty participantId should result in nil")
    }
    
    func testInvalidStudyId() {
        let invalidStudyId = "invalid"
        let enrollment = Enrollment(participantId: participantId, studyId: invalidStudyId, organizationId: organizationId)
        let urlComponents = ApiUtils.makeEnrollDeviceUrlComponents(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(urlComponents, "\(invalidStudyId) should result in nil")
    }
    
    func testInvalidOrgId() {
        let invalidOrgId = "orgid"
        let enrollment = Enrollment(participantId: participantId, studyId: studyId, organizationId: invalidOrgId)
        let urlComponents = ApiUtils.makeEnrollDeviceUrlComponents(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(urlComponents, "\(invalidOrgId) should result in nil")
    }
    
    func testUserDefaultsAssignment() {

        EnrollmentUtils.setUserDefaults(organizationId: organizationId, studyId: studyId, participantId: participantId)
        let defaults = UserDefaults.standard
        XCTAssertEqual(defaults.string(forKey: "organizationId"), organizationId)
        XCTAssertEqual(defaults.string(forKey: "studyId"), studyId)
        XCTAssertEqual(defaults.string(forKey: "participantId"), participantId)
    }
}
