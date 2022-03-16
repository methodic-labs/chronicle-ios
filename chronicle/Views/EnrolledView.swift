//
//  EnrolledView.swift
//  EnrolledView
//
//  Created by Giulia Campana on 8/12/21.
//

import SwiftUI

struct EnrolledView: View {
    
    @EnvironmentObject var viewModel: EnrollmentViewModel
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    EnrollmentDetailsView()
                    if (!appDelegate.sensorsAuthorized) {
                        SensorListView()
                    } else {
                        Text("Show upload history here!!!")
                    }
                    
                }.listStyle(.insetGrouped)
            }
            .navigationTitle("Chronicle")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await viewModel.fetchStudySensors()
            }
        }
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
        EnrolledView()
        ProgressIndicatorView(text: "In progress")
    }
}
