//
//  chronicleApp.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI

@main
struct chronicleApp: App {
    @ObservedObject var viewModel = EnrollmentViewModel()
    let isDeviceEnrolled = UserDefaults.standard.object(forKey: UserSettingsKeys.isEnrolled) as? Bool ?? false
    
    var body: some Scene {
        WindowGroup {
            if isDeviceEnrolled || viewModel.isEnrollmentDetailsViewVisible {
                // TODO: replace with view that accepts an instance of EnrollmentViewModel as a parameter.
                Text("TODO: replace with view showing participantId, studyId and optionally orgId")
            } else if viewModel.showEnrollmentSuccess {
                EnrollmentSuccessMessage(enrollmentViewModel: viewModel)
            } else {
                EnrollmentView(enrollmentViewModel: viewModel)
            }
        }
    }
}
