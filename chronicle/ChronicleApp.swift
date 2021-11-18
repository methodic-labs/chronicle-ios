//
//  ChronicleApp.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI

@main
struct ChronicleApp: App {
    @ObservedObject var viewModel = EnrollmentViewModel()
    let isDeviceEnrolled = UserDefaults.standard.object(forKey: UserSettingsKeys.isEnrolled) as? Bool ?? false
    
    var body: some Scene {
        WindowGroup {
            if isDeviceEnrolled || viewModel.isEnrollmentDetailsViewVisible {
                EnrolledView(enrollmentViewModel: viewModel)
            } else if viewModel.showEnrollmentSuccess {
                EnrollmentSuccessMessage(enrollmentViewModel: viewModel)
            } else {
                EnrollmentView(enrollmentViewModel: viewModel)
            }
        }
    }
}
