//
//  Enrollment.swift
//  Enrollment
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Describes user input values required to initiate device enrollment
struct Enrollment {
    var participantId: String = ""
    var studyId: String = ""
    var organizationId: String = ""
    
    mutating func setParticipantId(participantId :String) {
        self.participantId = participantId
    }
    
    mutating func setOrganizationId(organizationId: String) {
        self.organizationId = organizationId
    }
    
    mutating func setStudyId(studyId: String) {
        self.studyId = studyId
    }
}
