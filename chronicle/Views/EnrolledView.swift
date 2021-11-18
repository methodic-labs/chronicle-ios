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
    
    // convenient to read saved value from UserDefaults
    @AppStorage(UserSettingsKeys.lastUploadDate) var lastUploadDate: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AppHeader()
                Text("Participant ID:").fontWeight(.bold).padding(.bottom, 5)
                Text(enrollmentViewModel.participantId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                Text("Study ID:").fontWeight(.bold).padding(.bottom, 5)
                Text(enrollmentViewModel.studyId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                Text("Organization ID:").fontWeight(.bold).padding(.bottom, 5)
                Text(enrollmentViewModel.organizationId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                Text("Last Upload:").fontWeight(.bold).padding(.bottom, 5)
                Text(formatDate())
                    .foregroundColor(Color.gray)
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
    
    private func formatDate() -> String {
        guard let lastUploaded = lastUploadDate, let iSODate = ISO8601DateFormatter().date(from: lastUploaded)  else {
            return "Never"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd yyy jj:mm:ss")
        
        return dateFormatter.string(from: iSODate)
    }
}

struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView(appDelegate: AppDelegate(), enrollmentViewModel: EnrollmentViewModel())
    }
}
