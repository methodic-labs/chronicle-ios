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
    @AppStorage(UserSettingsKeys.lastRecordedDate) var lastRecordedDate: String?
    @AppStorage(UserSettingsKeys.lastRecordedDateUploaded) var lastRecordedDateUploaded: String?
    @AppStorage(UserSettingsKeys.itemsRemaining) var itemsRemaining: Int = 0
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
                
                Text("Local Last Recorded Date:").fontWeight(.medium).padding(.bottom,3)
                Text(formatDate(date: lastRecordedDate))
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                
                Text("Local Items Stored").fontWeight(.medium).padding(.bottom,3)
                Text(String(itemsRemaining))
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                
                Text("Last Recorded Date Uploaded:").fontWeight(.medium).padding(.bottom,3)
                Text(formatDate(date: lastRecordedDateUploaded))
                    .minimumScaleFactor(0.01)
                    .foregroundColor(Color.gray)
                    .padding(.bottom)
                
                Text("Last Upload:").fontWeight(.medium).padding(.bottom,3)
                Text(formatDate(date: lastUploadDate))
                    .foregroundColor(Color.gray)

                if isUploading {
                    ProgressIndicatorView(text: "Uploading Data...").padding(.top, 20)
                }
            }
            .padding([.top, .bottom], 10)
        }
    }
//    
//    private func lastRecordedDate() -> String {
//        return formatDate(date: lastRecordedDate)
//    }
//    
//    private func lastUploadDate() -> String {
//        return formatDate(date: lastUploadDate)
//    }
    private func formatDate(date : String?) -> String {
        guard let date = date, let iSODate = ISO8601DateFormatter().date(from: date)  else {
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
