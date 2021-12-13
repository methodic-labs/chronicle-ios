//
//  ChronicleApp.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI
import Foundation

@main
struct ChronicleApp: App {
    @ObservedObject var viewModel = EnrollmentViewModel()
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            if viewModel.isEnrollmentDetailsViewVisible {
                EnrolledView(appDelegate: appDelegate, enrollmentViewModel: viewModel)
            } else if viewModel.showEnrollmentSuccess {
                EnrollmentSuccessMessage(enrollmentViewModel: viewModel)
            } else {
                EnrollmentView(enrollmentViewModel: viewModel)
            }
        }.onChange(of: scenePhase) { phase in
            if phase == .background && viewModel.isEnrolled {
                appDelegate.scheduleMockDataBackgroundTask()
                appDelegate.scheduleUploadDataBackgroundTask()
            }
        }
    }
}
