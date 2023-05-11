//
//  EnrollmentDetailsView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 3/14/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import SwiftUI

struct EnrollmentDetailsView: View {
    @EnvironmentObject var viewModel: EnrollmentViewModel
    // convenient to read saved value from UserDefaults
    @AppStorage(UserSettingsKeys.lastUploadDate) var lastUploadDate: String?
    @AppStorage(UserSettingsKeys.isUploading) var isUploading: Bool = false

    var body: some View {
        Section(header: Text("Enrollment Details")) {
            VStack(alignment: .leading){
                Text("Study ID:").fontWeight(.medium) .padding(.bottom, 3)
                Text(viewModel.studyId)
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                Text("Participant ID:").fontWeight(.medium).padding(.bottom, 3)
                Text(viewModel.participantId)
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                Text("Last Upload:").fontWeight(.medium).padding(.bottom,3)
                Text(formatDate())
                    .foregroundColor(Color.gray)

                if isUploading {
                    ProgressIndicatorView(text: "Uploading Data...").padding(.top, 20)
                }
            }
            .padding([.top, .bottom], 10)
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

struct EnrollmentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EnrollmentDetailsView()
    }
}
