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
