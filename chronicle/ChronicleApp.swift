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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let isDeviceEnrolled = UserDefaults.standard.object(forKey: UserSettingsKeys.isEnrolled) as? Bool ?? false
    
    var body: some Scene {
        WindowGroup {
            if isDeviceEnrolled || viewModel.isEnrollmentDetailsViewVisible {
                EnrolledView(appDelegate: appDelegate, enrollmentViewModel: viewModel)
            } else if viewModel.showEnrollmentSuccess {
                EnrollmentSuccessMessage(enrollmentViewModel: viewModel)
            } else {
                EnrollmentView(enrollmentViewModel: viewModel)
            }
        }
    }
}
