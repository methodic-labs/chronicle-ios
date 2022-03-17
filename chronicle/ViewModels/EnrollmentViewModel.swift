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
    @Published var showEnrollmentError = false
    @Published var showEnrollmentSuccess = false
    @Published var enrolling = false
    @Published var isEnrollmentDetailsViewVisible = false //set to true in response to a button click
    @Published var isFetchingSensors = false
    
    @Published var participantId: String
    @Published var studyId: String
    @Published var deviceId: String
    @Published var sensors: [Sensor] = []
    @Published var sensorsToRemove: [Sensor] = [] ///previously saved sensors that are later removed from study settings
    @Published var isEnrolled  = false
    
    init() {
        participantId = settings.object(forKey: UserSettingsKeys.participantId) as? String ?? ""
        studyId = settings.object(forKey: UserSettingsKeys.studyId) as? String ?? ""
        deviceId = settings.object(forKey: UserSettingsKeys.deviceId) as? String ?? ""
        let savedSensors = settings.object(forKey: UserSettingsKeys.sensors) as? [String] ?? []
        if !savedSensors.isEmpty {
            self.sensors = savedSensors.map { Sensor.init(rawValue: $0)}.compactMap { $0 }
        }
        isEnrolled = Enrollment(participantId: participantId, studyId: studyId).isValid
    }
    
    func validateInput(enrollment: Enrollment) {
        invalidStudyId = !enrollment.isValidStudyId
        invalidParticipantId = !enrollment.isValidParticipant
    }
    
    // called when "Done" button in EnrollmentSuccessMessage view is clicked
    func onShowEnrollmentDetails() {
        isEnrollmentDetailsViewVisible = true
    }
    
    func initializeEnrollmentValues(_ enrollment: Enrollment) {
        guard enrollment.isValid else {
            return
        }
        participantId = enrollment.participantId
        studyId = enrollment.studyId!.uuidString
    }
    
    func setDeviceEnrolled() {
        self.isEnrolled = true
    }
    
    
    /** Invoked when the user clicks on "Enroll" button in the UI
     
     sample usage:
     Task {
     await model.enroll()
     }
     */
    func enroll() async {
        let enrollment = Enrollment(participantId: participantId, studyId: studyId)
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
                self.deviceId = deviceId
                
                // save user settings on device
                self.settings.set(self.participantId, forKey: UserSettingsKeys.participantId)
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
    
    func fetchStudySensors() async {
        /// If device has never fetched any sensors, indicate "Fetching study info" message on UI, when this is executing
        /// After successful fetch, if study has configured sensors, A sensorkit authorization sheet will be displayed to the user
        /// prompting to authorize configured sensors.
        
        if self.isFetchingSensors {
            return
        }
        
        if sensors.isEmpty {
            self.isFetchingSensors = true
        }
        let result = await ApiClient.getStudySensors()
        
        DispatchQueue.main.async {
            self.sensorsToRemove = self.sensors.filter { !result.contains($0)}
            self.sensors = Array(result)
            let arr = Array(result)
            self.sensors = arr
            self.settings.set(arr.map { $0.rawValue }, forKey: UserSettingsKeys.sensors)
            self.isFetchingSensors = false
        }
    }
}
