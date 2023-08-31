//
//  AppHeader.swift
//  AppHeader
//
//  Created by Giulia Campana on 8/16/21.
//

import SwiftUI

struct AppHeader: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Chronicle")
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(Color.primaryPurple)
                .lineLimit(nil)
                .padding(.top)
            Divider().padding(.bottom)
        }
    }
}

struct AppHeader_Previews: PreviewProvider {
    static var previews: some View {
        AppHeader()
    }
}
