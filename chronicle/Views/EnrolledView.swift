//
//  EnrolledView.swift
//  EnrolledView
//
//  Created by Giulia Campana on 8/12/21.
//

import SwiftUI

struct EnrolledView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    let appDelegate: AppDelegate
    var enrollmentViewModel: EnrollmentViewModel
    let defaults = UserDefaults.standard
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AppHeader()
                Text("Participant ID:").padding(.bottom)
                Text(defaults.string(forKey: UserSettingsKeys.participantId) ?? "").padding(.bottom)
                Text("Study ID:").padding(.bottom)
                Text(defaults.string(forKey: UserSettingsKeys.studyId) ?? "").padding(.bottom)
                Text("Organization ID:").padding(.bottom)
                Text(defaults.string(forKey: UserSettingsKeys.organizationId) ?? "").padding(.bottom)
            }
            .padding(.horizontal)
        }.onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                appDelegate.scheduleMockSensorTask()
            case .active:
                Timer.scheduledTimer(timeInterval: 30, target: appDelegate, selector: #selector(appDelegate.mockSensorData), userInfo: nil, repeats: true)
                Timer.scheduledTimer(timeInterval: 30, target: appDelegate, selector: #selector(appDelegate.uploadSensorData), userInfo: nil, repeats: true)
            default: break
                
            }
        }
    }
}

struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView(appDelegate: AppDelegate(), enrollmentViewModel: EnrollmentViewModel())
    }
}
