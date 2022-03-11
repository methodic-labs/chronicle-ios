//
//  EnrolledView.swift
//  EnrolledView
//
//  Created by Giulia Campana on 8/12/21.
//

import SwiftUI

struct EnrolledView: View {

    let appDelegate: AppDelegate
    var enrollmentViewModel: EnrollmentViewModel

    // convenient to read saved value from UserDefaults
    @AppStorage(UserSettingsKeys.lastUploadDate) var lastUploadDate: String?
    @AppStorage(UserSettingsKeys.isUploading) var isUploading: Bool = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AppHeader()
                Text("Study ID:").fontWeight(.bold).padding(.bottom, 5)
                Text(enrollmentViewModel.studyId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                
                Text("Participant ID:").fontWeight(.bold).padding(.bottom, 5)
                Text(enrollmentViewModel.participantId)
                    .scaledToFit()
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                
                
                Text("Last Upload:").fontWeight(.bold).padding(.bottom, 5)
                Text(formatDate())
                    .foregroundColor(Color.gray)

                if isUploading {
                    ProgressIndicatorView(text: "Uploading Data...").padding(.top, 20)
                }
                else if enrollmentViewModel.isFetchingSensors {
                    ProgressIndicatorView(text: "Fetching study information...").padding(.top, 20)
                }
            }
            .padding(.horizontal)
        }.onAppear {
            Task {
                await enrollmentViewModel.fetchStudySensors()
                appDelegate.requestSensorReaderAuthorization(
                    valid: enrollmentViewModel.sensors,
                    invalid: enrollmentViewModel.sensorsToRemove
                )
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

struct ProgressIndicatorView: View {
    let text: String
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.body)
                .foregroundColor(.gray)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            Spacer()
        }
    }
}

struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView(appDelegate: AppDelegate(), enrollmentViewModel: EnrollmentViewModel())
        ProgressIndicatorView(text: "In progress")
    }
}
