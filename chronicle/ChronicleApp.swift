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
    let coreDataProvider: SensorDataProvider = .shared
    let interval: TimeInterval = 15 * 60 // 15 minutes
    
    var body: some Scene {
        WindowGroup {
            if isDeviceEnrolled || viewModel.isEnrollmentDetailsViewVisible {
                // TODO: replace with view that accepts an instance of EnrollmentViewModel as a parameter.
                Text("TODO: replace with view showing participantId, studyId and optionally orgId").onAppear {
                    Timer.scheduledTimer(
                        timeInterval: 15,
                        target: coreDataProvider,
                        selector: #selector(coreDataProvider.mockSensorData),
                        userInfo: nil,
                        repeats: true
                    )
                }
            } else if viewModel.showEnrollmentSuccess {
                EnrollmentSuccessMessage(enrollmentViewModel: viewModel)
            } else {
                EnrollmentView(enrollmentViewModel: viewModel)
            }
        }
    }
}
