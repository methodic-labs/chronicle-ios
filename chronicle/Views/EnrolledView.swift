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

    var sensorReader: SensorReader {
        return SensorReader(appDelegate: appDelegate)
    }

    // convenient to read saved value from UserDefaults
    @AppStorage(UserSettingsKeys.lastUploadDate) var lastUploadDate: String?
    @AppStorage(UserSettingsKeys.isUploading) var isUploading: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AppHeader()
                Text("Organization ID:").fontWeight(.bold).padding(.bottom, 5)
                Text(enrollmentViewModel.organizationId)
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
                    UploadingProgress().padding(.top, 20)
                }
            }
            .padding(.horizontal)
        }.onAppear {
            sensorReader.configure()
            uploadData()
        }
    }
    
    private func uploadData() {
        DispatchQueue.global().async {

            // schedule a repeating task to persist locally stored data to server
            let startDate = Date().addingTimeInterval(5) // 5 seconds from now

            let uploadDataTimer = Timer(fireAt: startDate.addingTimeInterval(5), interval: 15 * 60, target: appDelegate, selector: #selector(appDelegate.uploadSensorData), userInfo: nil, repeats: true)

            let runLoop = RunLoop.main
            runLoop.run()

            runLoop.add(uploadDataTimer, forMode: RunLoop.Mode.common)
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

struct UploadingProgress: View {
    var body: some View {
        HStack {
            Spacer()
            Text("Uploading Data...")
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
        UploadingProgress()
    }
}
