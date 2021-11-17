//
//  EnrolledView.swift
//  EnrolledView
//
//  Created by Giulia Campana on 8/12/21.
//

import SwiftUI

struct EnrolledView: View {
    var enrollmentViewModel: EnrollmentViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AppHeader()
                Text("Participant ID:").padding(.bottom)
                Text(enrollmentViewModel.participantId).padding(.bottom)
                Text("Study ID:").padding(.bottom)
                Text(enrollmentViewModel.studyId).padding(.bottom)
                Text("Organization ID:").padding(.bottom)
                Text(enrollmentViewModel.organizationId).padding(.bottom)
            }
            .padding(.horizontal)
        }
    }
}

struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView(enrollmentViewModel: EnrollmentViewModel())
    }
}
