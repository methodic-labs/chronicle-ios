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
    
    static func getCurrentEnrollment() -> Self {
        let settings = UserDefaults.standard
        
        let participantId = settings.object(forKey: UserSettingsKeys.participantId) as? String ?? ""
        let studyId = settings.object(forKey: UserSettingsKeys.studyId) as? String ?? ""
        let organizationId = settings.object(forKey: UserSettingsKeys.organizationId) as? String ?? ""
        
        return Enrollment(participantId: participantId, studyId: studyId, organizationId: organizationId)
    }
}

