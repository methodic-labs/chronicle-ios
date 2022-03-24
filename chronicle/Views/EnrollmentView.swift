//
//  EnrollmentView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI

struct EnrollmentView: View {
    
    @EnvironmentObject var viewModel: EnrollmentViewModel
    
    init() {
        Theme.navigationBarStyle()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Device Enrollment")) {
                    VStack(alignment: .leading) {
                        InputFieldView(
                            label: "Study ID",
                            placeholder: "Enter your Study ID",
                            inputId: $viewModel.studyId, invalidInput: $viewModel.invalidStudyId
                        )
                        InputFieldView(
                            label: "Participant ID",
                            placeholder: "Enter your Participant ID",
                            inputId: $viewModel.participantId,
                            invalidInput: $viewModel.invalidParticipantId
                        )
                        HStack {
                            Spacer()
                            if viewModel.enrolling == true {
                                ProgressView().padding(10)
                            }
                            else {
                                Button {
                                    Task {
                                        await viewModel.enroll()
                                    }
                                } label: {
                                    Text("Enroll Device")
                                        .foregroundColor(.white)
                                        .padding(10)
                                }
                                .background(Color.primaryPurple)
                                .cornerRadius(8)
                                .disabled(viewModel.enrolling == true)
                                .alert(isPresented: $viewModel.showEnrollmentSuccess) {
                                    Alert(
                                        title: Text("Device Enrolled"),
                                        message: Text("Your device was successfully enrolled."),
                                        dismissButton: .default (
                                            Text("OK"),
                                            action: viewModel.setDeviceEnrolled
                                        )
                                    )
                                }
                            }
                        }
                    }
                    .padding([.bottom, .top], 10)
                }
            }
            .alert(isPresented: $viewModel.showEnrollmentError) {
                Alert(
                    title: Text("Device Enrollment Failed"),
                    message: Text("Failed to enroll device. Please double check that the Study ID and the Participant ID are correct. If the problem persists, please contact your study administrator."),
                    dismissButton: .default(Text("OK")))
            }
            .navigationTitle("Chronicle")
            .navigationBarTitleDisplayMode(.inline)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var model = EnrollmentViewModel()
    static var previews: some View {
        EnrollmentView()
            .environmentObject(EnrollmentViewModel())
    }
}
