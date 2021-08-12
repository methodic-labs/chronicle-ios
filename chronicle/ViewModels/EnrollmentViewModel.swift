//
//  EnrollmentViewModel.swift
//  EnrollmentViewModel
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Grants view access to the Enrollment model.  Keeps track of input values and errors
class EnrollmentViewModel: ObservableObject {
    
    @Published var invalidParticipantId = false
    @Published var invalidStudyId = false
    @Published var invalidOrganizationId = false
    @Published var showEnrollmentError = false
    @Published var showEnrollmentSuccess = false
    @Published var withOrgId = true
    @Published var enrolling = false
    
    @Published var participantId: String = ""
    @Published var studyId: String = ""
    @Published var organizationId :String = ""


    func validateInput() {
        invalidStudyId = UUID.init(uuidString: studyId) == nil
        invalidParticipantId = participantId.isEmpty
        invalidOrganizationId = withOrgId && UUID.init(uuidString: organizationId) == nil
    }
    
    /** Invoked when the user clicks on "Enroll" button in the UI
     
        sample usage:
        Task {
            await model.enroll()
        }
     */
    func enroll() async {
        
        validateInput()
        if (invalidStudyId || invalidParticipantId || invalidOrganizationId ) {
            return
        }
        
        self.enrolling = true
        self.showEnrollmentError = false
        
        let enrollment = Enrollment(participantId: participantId, studyId: studyId, organizationId: organizationId)
        
        await ApiClient.enrollDevice(enrollment: enrollment, withOrgId: withOrgId) {
            DispatchQueue.main.async {
                self.showEnrollmentError = false
                self.enrolling = false
            }
        } onError: { error in
            DispatchQueue.main.async {
                self.showEnrollmentError = true
                self.enrolling = false
            }
        }
    }
}
