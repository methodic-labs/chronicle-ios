//
//  EnrollmentViewModel.swift
//  EnrollmentViewModel
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Grants view access to the Enrollment model.  Keeps track of input values and errors
class EnrollmentViewModel: ObservableObject {
    /// store key value pairs in user's default database
    let settings = UserDefaults.standard
    
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
        
        await ApiClient.enrollDevice(enrollment: enrollment, withOrgId: withOrgId) { deviceId in
            DispatchQueue.main.async {
                self.showEnrollmentError = false
                self.showEnrollmentSuccess = true
                self.enrolling = false
                
                // save user settings on device
                self.settings.set(self.participantId, forKey: UserSettingsKeys.participantId)
                self.settings.set(self.organizationId, forKey: UserSettingsKeys.organizationId)
                self.settings.set(self.studyId, forKey: UserSettingsKeys.studyId)
                self.settings.set(true, forKey: UserSettingsKeys.isEnrolled)
                self.settings.set(deviceId, forKey: UserSettingsKeys.deviceId)
                
            }
        } onError: { error in
            DispatchQueue.main.async {
                self.showEnrollmentError = true
                self.enrolling = false
            }
        }
    }
}
