//
//  EnrollmentViewModel.swift
//  EnrollmentViewModel
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Grants view access to the Enrollment model.  Keeps track of input values and errors
class EnrollmentViewModel: ObservableObject {
    // initializes new Enrollment with participantId, studyId & organizationId set to empty strings
    private var enrollmentDetails = Enrollment()

    @Published var invalidParticipantId = false
    @Published var invalidStudyId = false
    @Published var invalidOrganizationId = false
    @Published var showEnrollmentError = false
    @Published var showEnrollmentSuccess = false
    @Published var withOrgId = true
    
    @Published var participantId: String
    @Published var studyId: String
    @Published var organizationId :String
    
    init() {
        participantId = enrollmentDetails.participantId
        studyId = enrollmentDetails.studyId
        organizationId = enrollmentDetails.organizationId
    }
    
    // invoked when participantId input changes
    func onChangeParticipantId(participantId: String) {
        self.participantId = participantId
        enrollmentDetails.participantId = participantId
        invalidParticipantId = participantId.isEmpty
    }
    
    // invoked when studyId input changes
    func onChangeStudyId(studyId: String) {
        self.studyId = studyId
        enrollmentDetails.studyId = studyId
        invalidStudyId = UUID.init(uuidString: studyId) == nil
    }
    
    // invoked when organizationId input changes
    func onChangeOrganizationId(organizationId :String) {
        self.organizationId = organizationId
        enrollmentDetails.organizationId = organizationId
        invalidOrganizationId = withOrgId && UUID.init(uuidString: organizationId) == nil
    }

    // invoked when the user clicks on "Enroll" button in the UI
    func enroll() async {
        await ApiClient.enrollDevice(enrollment: enrollmentDetails, withOrgId: withOrgId) {
            self.showEnrollmentSuccess = true
        } onError: { error in
            switch error {
            case .invalidInput(let invalidParticipantId, let invalidStudyId, let invalidOrganizationId):
                
                self.invalidStudyId = invalidStudyId
                self.invalidParticipantId = invalidParticipantId
                self.invalidOrganizationId = invalidOrganizationId
                
            default:
                self.showEnrollmentError = true
            }
        }
    }
}
