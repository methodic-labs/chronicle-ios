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
        
                    .onOpenURL { url in
                        
                        // handle when app is launched from url conforming to custom scheme
                        
                        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                              let params = components.queryItems else {
                            return
                        }
                        
                        if let participantId = params.first(where: { $0.name == "participantId" })?.value,
                           let studyId = params.first(where: { $0.name == "studyId" })?.value,
                           let organizationId = params.first(where: { $0.name == "organizationId" })?.value {

                            
                            let enrollment = Enrollment(participantId: participantId, studyId: studyId, organizationId: organizationId)
                            if (enrollment.isValid) {
                                viewModel.initializeEnrollmentValues(enrollment)
                            }
                            
                        }
                    }
            }
        }.onChange(of: scenePhase) { phase in
            if phase == .background && viewModel.isEnrolled {
                appDelegate.scheduleMockDataBackgroundTask()
                appDelegate.scheduleUploadDataBackgroundTask()
            }
        }
    }
}
