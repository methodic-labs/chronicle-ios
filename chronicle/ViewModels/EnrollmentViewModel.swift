//
//  EnrollmentViewModel.swift
//  EnrollmentViewModel
//
//  Created by Alfonce Nzioka on 8/11/21.
//

import Foundation

/// Generic state manager for views. Handles intents and sets up binding for various properties
class EnrollmentViewModel: ObservableObject {
    /// store key value pairs in user's default database
    let settings = UserDefaults.standard
    
    @Published var invalidParticipantId = false
    @Published var invalidStudyId = false
    @Published var invalidOrganizationId = false
    @Published var showEnrollmentError = false
    @Published var showEnrollmentSuccess = false
    @Published var enrolling = false
    @Published var isEnrollmentDetailsViewVisible = false //set to true in response to a button click
    
    @Published var participantId: String
    @Published var studyId: String
    @Published var organizationId :String
    
    
    init() {
        participantId = settings.object(forKey: UserSettingsKeys.participantId) as? String ?? ""
        studyId = settings.object(forKey: UserSettingsKeys.studyId) as? String ?? ""
        organizationId = settings.object(forKey: UserSettingsKeys.organizationId) as? String ?? ""
    }
    
    func validateInput(enrollment: Enrollment) {
        invalidStudyId = !enrollment.isValidStudyId
        invalidParticipantId = !enrollment.isValidParticipant
        invalidOrganizationId = !enrollment.isValidOrgId
    }
    
    func isDeviceEnrolled() -> Bool {
        return settings.object(forKey: UserSettingsKeys.isEnrolled) as? Bool ?? false
    }
    
    // called when "Done" button in EnrollmentSuccessMessage view is clicked
    func onShowEnrollmentDetails() {
        isEnrollmentDetailsViewVisible = true
    }
    
    /** Invoked when the user clicks on "Enroll" button in the UI
     
     sample usage:
     Task {
        await model.enroll()
     }
     */
    func enroll() async {
        let enrollment = Enrollment(participantId: participantId, studyId: studyId, organizationId: organizationId)
        validateInput(enrollment: enrollment)
        
        guard enrollment.isValid else {
            return
        }
        
        self.enrolling = true
        self.showEnrollmentError = false
        
        
        await ApiClient.enrollDevice(enrollment: enrollment) { deviceId in
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
