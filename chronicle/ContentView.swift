//
//  ContentView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 8/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var hasOrgId: Bool = true
    
    let filled = "circle.inset.filled"
    let empty = "circle"

    var body: some View {
        VStack(alignment: .leading) {
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
                InputFieldView(label: "Enter your Organization ID")
            }
            InputFieldView(label: "Enter your Study ID")
            InputFieldView(label: "Enter your Participant ID")
            
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
    @State private var studyId: String = ""
    
    var body: some View {
        TextField(label, text: $studyId)
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
