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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AppHeader()
                Text("Participant ID:").fontWeight(.bold).padding(.bottom)
                Text(enrollmentViewModel.participantId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                Text("Study ID:").fontWeight(.bold).padding(.bottom)
                Text(enrollmentViewModel.studyId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                Text("Organization ID:").fontWeight(.bold).padding(.bottom)
                Text(enrollmentViewModel.organizationId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
            }
            .padding(.horizontal)
        }.onAppear {
            appDelegate.mockSensorData()
        }
    }
}

struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView(appDelegate: AppDelegate(), enrollmentViewModel: EnrollmentViewModel())
    }
}
