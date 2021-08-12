//
//  ContentView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var enrollmentViewModel = EnrollmentViewModel()
    
    @State var hasOrgId: Bool = true
    
    let filled = "circle.inset.filled"
    let empty = "circle"

    var body: some View {
        VStack(alignment: .leading) {
            Text("Chronicle")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(Color(red: 109/255, green: 73/255, blue: 254/255, opacity: 1.0))
                .lineLimit(nil)
            Divider().padding(.bottom)
            Text("Do you have an organization ID?")
                .padding(.bottom)

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

            if hasOrgId == true {
                InputFieldView(label: "Enter your Organization ID", inputId: $enrollmentViewModel.organizationId)
            }
            InputFieldView(label: "Enter your Study ID", inputId: $enrollmentViewModel.studyId)
            InputFieldView(label: "Enter your Participant ID", inputId: $enrollmentViewModel.participantId)
            
            HStack {
                Spacer()
                Button(action: {}, label: {
                    Text("Enroll Device")
                        .foregroundColor(.white)
                        .padding(10)
                })
                .background(Color(red: 109/255, green: 73/255, blue: 254/255, opacity: 1.0))
                .cornerRadius(8)
            }
            Spacer()
        }
        .padding(.horizontal)
        .textFieldStyle(.roundedBorder)
    }
}

struct InputFieldView: View {
    let label: String
    @Binding var inputId: String
    
    var body: some View {
        TextField(label, text: $inputId)
            .padding([.top, .bottom])
            .disableAutocorrection(true)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView().preferredColorScheme(.dark)
    }
}
