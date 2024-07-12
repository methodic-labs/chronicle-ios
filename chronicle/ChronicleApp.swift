//
//  ChronicleApp.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI
import Foundation
import OSLog

@main
struct ChronicleApp: App {
    let persistenceController = PersistenceController.shared
    
    @ObservedObject var viewModel = EnrollmentViewModel()
    @Environment(\.scenePhase) var scenePhase
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "AppDelegate")
    
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
                let enrolledDate = UserDefaults.standard.object(forKey: UserSettingsKeys.enrolledDate) as? Date
                
                //This will only happen if phone is updated after being enrolled. This will make sure we don't miss any data from
                //added sensors at the risk of missing data that falls off the query window.
                if enrolledDate == nil {
                    logger.info("Missing data from upgrade detected. Setting enrollment date to now.")
                    let fourWeeksAgo = Calendar.current.date(byAdding: .day, value: 28
                                                             , to: Date())!
                    UserDefaults.standard.set(fourWeeksAgo,forKey: UserSettingsKeys.enrolledDate)
                }
                
                appDelegate.fetchSensorSamples()
                appDelegate.uploadSensorData()
            }
        }
    }
}
