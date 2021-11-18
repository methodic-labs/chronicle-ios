//
//  Enrollment.swift
//  Enrollment
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Describes user input values required to initiate device enrollment
struct Enrollment {
    let participantId: String
    let studyId: UUID?
    let organizationId: UUID?
    
    var isValidParticipant: Bool {
        !participantId.isEmpty
    }
    
    var isValidStudyId: Bool {
        studyId != nil
    }
    
    var isValidOrgId: Bool {
        organizationId != nil
    }
    
    var isValid: Bool {
        isValidParticipant && isValidStudyId && isValidOrgId
    }
    
    init(participantId: String, studyId: String, organizationId: String) {
        self.participantId = participantId
        self.studyId = UUID.init(uuidString: studyId)
        self.organizationId = UUID.init(uuidString: organizationId)
    }
    
}

