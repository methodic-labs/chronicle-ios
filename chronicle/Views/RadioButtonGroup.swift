//
//  RadioButtonGroup.swift
//  RadioButtonGroup
//
//  Created by Giulia Campana on 8/18/21.
//

import SwiftUI

struct RadioButtonGroup: View {
    @Binding var hasOrgId: Bool
    
    let filled = "circle.inset.filled"
    let empty = "circle"
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    hasOrgId = true
                 } label: {
                     Image(systemName: hasOrgId ? filled : empty)
                 }
                 Text("Yes")
                 Spacer()
            }
            HStack {
                Button {
                    hasOrgId = false
                 } label: {
                     Image(systemName: !hasOrgId ? filled : empty)
                 }
                 Text("No")
                 Spacer()
            }
        }
        .foregroundColor(Color.primaryPurple)
    }
}
