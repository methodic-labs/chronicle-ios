//
//  EnrollmentForm.swift
//  EnrollmentForm
//
//  Created by Giulia Campana on 8/19/21.
//

import SwiftUI

struct EnrollmentForm: View {
    
    @ObservedObject var enrollmentViewModel = EnrollmentViewModel()

    var body: some View {
        if enrollmentViewModel.showEnrollmentSuccess == false {
            ScrollView {
                VStack(alignment: .leading) {
                    AppHeader()
                    Text("Do you have an organization ID?")
                        .padding(.bottom)
                    RadioButtonGroup(hasOrgId: $enrollmentViewModel.withOrgId)

                    if enrollmentViewModel.withOrgId == true {
                        InputFieldView(label: "Enter your Organization ID", inputId: $enrollmentViewModel.organizationId, invalidInput: $enrollmentViewModel.invalidOrganizationId)
                    }
                    InputFieldView(label: "Enter your Study ID", inputId: $enrollmentViewModel.studyId, invalidInput: $enrollmentViewModel.invalidStudyId)
                    InputFieldView(label: "Enter your Participant ID", inputId: $enrollmentViewModel.participantId, invalidInput: $enrollmentViewModel.invalidParticipantId)

                    HStack {
                        Spacer()
                        if enrollmentViewModel.enrolling == true {
                            ProgressView().padding(10)
                        }
                        else {
                            Button(action: {
                                Task {
                                    await enrollmentViewModel.enroll()
                                }
                            }, label: {
                                Text("Enroll Device")
                                    .foregroundColor(.white)
                                    .padding(10)
                            })
                                .background(Color.primaryPurple)
                            .cornerRadius(8)
                            .disabled(enrollmentViewModel.enrolling == true)
                        }
                    }
                    if enrollmentViewModel.showEnrollmentError {
                        EnrollmentFailureMessage()
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .textFieldStyle(.roundedBorder)
            }
        }
        else {
            ScrollView {
                EnrollmentSuccessMessage()
            }
        }
    }
}

struct EnrollmentForm_Previews: PreviewProvider {
    static var previews: some View {
        EnrollmentForm()
    }
}
