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
    
    let persitenceController: PersistenceController = .shared
    let dataManager: SensorDataManager = .shared

    let interval: TimeInterval = 15 * 60 // 15 minutes
        
    var isDeviceEnrolled: Bool {
        !viewModel.deviceId.isEmpty
    }
    
    var body: some Scene {
        WindowGroup {
            if isDeviceEnrolled || viewModel.isEnrollmentDetailsViewVisible {
                // TODO: replace with view that accepts an instance of EnrollmentViewModel as a parameter.
                Text("TODO: replace with view showing participantId, studyId and optionally orgId").onAppear {
                    Timer.scheduledTimer(
                        timeInterval: 10,
                        target: dataManager,
                        selector: #selector(dataManager.mockSensorData),
                        userInfo: nil,
                        repeats: true
                    )

                    Timer.scheduledTimer(
                        timeInterval: 10,
                        target: dataManager,
                        selector: #selector(dataManager.uploadMockSensorData(timer:)),
                        userInfo: ["deviceId": viewModel.deviceId],
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
