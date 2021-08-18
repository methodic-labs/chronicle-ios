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
                .foregroundColor(Color(red: 109/255, green: 73/255, blue: 254/255, opacity: 1.0))
                .lineLimit(nil)
                .padding(.top)
            Divider().padding(.bottom)
        }
        .padding(.horizontal)
    }
}

struct AppHeader_Previews: PreviewProvider {
    static var previews: some View {
        AppHeader()
    }
}
