//
//  CollapsibleView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 4/20/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import SwiftUI

struct CollapsibleView<Content: View>: View {
    @State var label: () -> Text
    @State var content: () -> Content
    
    @State private var collapsed: Bool = true
    
    var body: some View {
        VStack {
            Button {
                self.collapsed.toggle()
            } label: {
                HStack {
                    self.label()
                    Spacer()
                    Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                }
                .padding(.bottom, 1)
                .background(Color.white.opacity(0.01))
            }.buttonStyle(PlainButtonStyle())
            
            VStack {
                self.content()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: collapsed ? 0 : .none)
            .clipped()
            .animation(.easeOut)
            .transition(.slide)
        }
    }
}

//struct CollapsibleView_Previews: PreviewProvider {
//    static var previews: some View {
//        CollapsibleView()
//    }
//}
