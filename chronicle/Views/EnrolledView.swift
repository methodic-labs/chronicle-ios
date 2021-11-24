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
            
            // schedule a repeating task to create fake sensor data and save to database
            let startDate = Date().addingTimeInterval(5) // 5 seconds from now
            
            let timer = Timer(fireAt: startDate, interval: 15 * 60, target: appDelegate, selector: #selector(appDelegate.mockSensorData), userInfo: nil, repeats: true)
            
            let runLoop = RunLoop.current

            runLoop.add(timer, forMode: RunLoop.Mode.common)
            runLoop.run()

        }
    }
}

struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView(appDelegate: AppDelegate(), enrollmentViewModel: EnrollmentViewModel())
    }
}
