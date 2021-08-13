//
//  ContentView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var enrollmentViewModel = EnrollmentViewModel()

    var body: some View {
        if enrollmentViewModel.showEnrollmentSuccess == false {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Chronicle")
                        .font(.title)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(red: 109/255, green: 73/255, blue: 254/255, opacity: 1.0))
                        .lineLimit(nil)
                        .padding(.top)
                    Divider().padding(.bottom)
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
                            .background(Color(red: 109/255, green: 73/255, blue: 254/255, opacity: 1.0))
                            .cornerRadius(8)
                            .disabled(enrollmentViewModel.enrolling == true)
                        }
                    }
                    if enrollmentViewModel.showEnrollmentError {
                        Text("Failed to enroll device. Please double check that the Organization ID, Study ID and the Participant ID are correct. If the problem persists, please contact your study administrator.")
                            .padding(.top)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .textFieldStyle(.roundedBorder)
            }
        }
        else {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Your device has been enrolled! Thank you for participating in our study!\n\nYou have successfully installed Chronicle and may now close the application. Chronicle will continue to function as a background process on your device while the application is closed. To stop sending information to the researchers - for instance, at the end of the study - simply uninstall this app. If you have questions or concerns, please contact a member of your research team.")
                    // later, add "Done" button which navigates to home page
                    Spacer()
                }.padding()
            }
        }
    }
}

struct RadioButtonGroup: View {
    @Binding var hasOrgId: Bool
    
    let filled = "circle.inset.filled"
    let empty = "circle"
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.fixed(30)), GridItem()]) {
            LazyVGrid(columns: [GridItem()], alignment: .leading) {
                Button(action: {
                    hasOrgId = true
                }, label: {
                    Image(systemName: hasOrgId ? filled : empty)
                })
                Spacer()
                Button(action: {
                    hasOrgId = false
                }, label: {
                    Image(systemName: !hasOrgId ? filled : empty)
                })
            }
            LazyVGrid(columns: [GridItem()], alignment: .leading) {
                Text("Yes")
                Spacer()
                Text("No")
            }
        }
        .foregroundColor(Color(red: 109/255, green: 73/255, blue: 254/255, opacity: 1.0))
    }
}

struct InputFieldView: View {
    let label: String
    @Binding var inputId: String
    @Binding var invalidInput: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).strokeBorder(lineWidth: 0.3).foregroundColor(Color(invalidInput ? .red : .gray)).frame(minHeight: 40, maxHeight: 40)
            TextField(label, text: $inputId)
                .padding(.leading)
                .textFieldStyle(.plain)
                .disableAutocorrection(true)
        }.padding([.top, .bottom])
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView().preferredColorScheme(.dark)
    }
}
