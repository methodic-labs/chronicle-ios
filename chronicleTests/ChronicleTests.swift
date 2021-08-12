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
        let urlComponents = ApiUtils.makeEnrollDeviceComponentsWithOrg(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNotNil(urlComponents, "should not be nil")
        XCTAssertEqual(
            urlComponents?.path,
            "/chronicle/v2/\(organizationId)/\(studyId)/\(participantId)/\(deviceId)/enroll"
        )
        XCTAssertEqual(urlComponents?.host, "api.openlattice.com")
        XCTAssertEqual(urlComponents?.scheme, "https")
    }
    
    func testEnrollmentWithoutOrg() {
        let enrollment = Enrollment(participantId: participantId, studyId: studyId, organizationId: organizationId)
        let urlComponents = ApiUtils.makeEnrollDeviceComponentsWithoutOrg(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNotNil(urlComponents, "should not be nil")
        XCTAssertEqual(
            urlComponents?.path,
            "/chronicle/study/\(studyId)/\(participantId)/\(deviceId)"
        )
    }
    
    func testInvalidParticipantId() {
        let enrollment = Enrollment(participantId: "", studyId: studyId, organizationId: organizationId)
        let urlComponents = ApiUtils.makeEnrollDeviceComponentsWithOrg(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(urlComponents, "Empty participantId should result in nil")
    }
    
    func testInvalidStudyId() {
        let invalidStudyId = "invalid"
        let enrollment = Enrollment(participantId: participantId, studyId: invalidStudyId, organizationId: organizationId)
        let urlComponents = ApiUtils.makeEnrollDeviceComponentsWithOrg(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(urlComponents, "\(invalidStudyId) should result in nil")
    }
    
    func testInvalidOrgId() {
        let invalidOrgId = "orgid"
        let enrollment = Enrollment(participantId: participantId, studyId: studyId, organizationId: invalidOrgId)
        let urlComponents = ApiUtils.makeEnrollDeviceComponentsWithOrg(enrollment: enrollment, deviceId: deviceId)
        
        XCTAssertNil(urlComponents, "\(invalidOrgId) should result in nil")
    }
}
