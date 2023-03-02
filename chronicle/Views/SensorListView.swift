//
//  SensorListView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 3/14/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import SwiftUI

struct SensorListView: View {
    @EnvironmentObject var viewModel: EnrollmentViewModel
    @EnvironmentObject var appDelegate: AppDelegate
    
    let bulletPoint: String = "\u{2022}"
    
    var body: some View {
        
        Section(header: Text("Sensor Authorization")) {
            if (viewModel.isFetchingSensors) {
                ProgressIndicatorView(text: "Fetching study authorized sensors...")
                    .padding()
            } else if (!viewModel.sensors.isEmpty) {
                VStack(alignment: .leading) {
                    Text("Study needs authorization to record data from these sensors:")
                        .fontWeight(.medium)
                        .padding(.bottom, 10)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
            
                    ForEach(viewModel.sensors, id: \.self) { sensor in
                        Text("\(bulletPoint) \(sensor.localizedDescription)")
                            .padding(.bottom, 5)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Spacer()
                        Button {
                            appDelegate.requestSensorReaderAuthorization(
                                valid: viewModel.sensors,
                                invalid: viewModel.sensorsToRemove
                            )
                        } label: {
                            Text("Authorize")
                                .foregroundColor(.white)
                                .padding(10)
                        }
                        .background(Color.primaryPurple)
                        .cornerRadius(8)
                        .alert(isPresented: $appDelegate.authorizationError) {
                            Alert(
                                title: Text("Authorization Error"),
                                message: Text("Failed to authorize sensors on device. Please try again later, or contact your study adminstrator if this problem persists.")
                            )
                        }
                    }
                }.padding([.top, .bottom], 10)
            } else {
                VStack (alignment: .leading, spacing: 10) {
                    Text("No authorized sensors found for study. Please try again later, or contact your study administrator if this problem persists.")
                    HStack {
                        Spacer()
                        Button {
                            Task {
                                await viewModel.fetchStudySensors()
                            }
                        } label: {
                            Text("Retry")
                                .foregroundColor(.white)
                                .padding([.bottom, .top], 10)
                                .padding([.leading, .trailing], 20)
                                
                        }
                        .background(Color.primaryPurple)
                        .cornerRadius(8)
                    }
                }.padding([.top, .bottom], 10)
                
            }
        }
    }
}

struct SensorListView_Previews: PreviewProvider {
    static var previews: some View {
        SensorListView()
    }
}
