//
//  HealthKitAuthorizationView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 11/19/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import SwiftUI

struct HealthKitAuthorizationView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        Section(header: Text("Healthkit Authorization")) {
            VStack(alignment: .leading) {
                Text("HealthKit authorization is required in order for app to function correctly.")
                    .fontWeight(.medium)
                    .padding(.bottom, 10)
                    .font(.subheadline)
                HStack {
                    Spacer()
                    Button {
                        appDelegate.requestHealthKitAuthorization()
                    } label: {
                        Text("Authorize")
                            .foregroundColor(.white)
                            .padding(10)
                    }
                    .background(Color.primaryPurple)
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct HealthKitAuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        HealthKitAuthorizationView()
    }
}
