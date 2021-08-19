//
//  EnrolledView.swift
//  EnrolledView
//
//  Created by Giulia Campana on 8/12/21.
//

import SwiftUI

struct EnrolledView: View {
    let defaults = UserDefaults.standard
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                AppHeader()
                Text("Study ID:").padding(.bottom)
                Text(defaults.string(forKey: "studyId") ?? "").padding(.bottom)
                Text("Participant ID:").padding(.bottom)
                Text(defaults.string(forKey: "participantId") ?? "").padding(.bottom)
            }
            .padding(.horizontal)
        }
    }
}

struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView()
    }
}
