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
    let persistenceController = PersistenceController.shared
    
    @ObservedObject var viewModel = EnrollmentViewModel()
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    
    var body: some Scene {
        WindowGroup {
            if viewModel.isEnrolled {
                EnrolledView()
                    .environmentObject(viewModel)
                    .environment(\.managedObjectContext, persistenceController.persistentContainer!.viewContext)
            } else {
                EnrollmentView()
                    .environmentObject(viewModel)
                    .onOpenURL { url in
                        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
                              let params = components.queryItems else {
                                  return
                              }
                        if let participantId = params.first(where: { $0.name == "participantId" })?.value,
                           let studyId = params.first(where: { $0.name == "studyId" })?.value {
                            let enrollment = Enrollment(participantId: participantId, studyId: studyId)
                            if (enrollment.isValid) {
                                viewModel.initializeEnrollmentValues(enrollment)
                            }
                        }
                    }
            }
        }.onChange(of: scenePhase) { phase in
            if phase == .active && viewModel.isEnrolled {
                appDelegate.uploadSensorData()
                appDelegate.fetchSensorSamples()
            }
        }
    }
}
