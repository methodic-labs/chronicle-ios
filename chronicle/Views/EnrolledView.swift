//
//  EnrolledView.swift
//  EnrolledView
//
//  Created by Giulia Campana on 8/12/21.
//

import SwiftUI

struct EnrolledView: View {
    
    @EnvironmentObject var viewModel: EnrollmentViewModel
    @EnvironmentObject var appDelegate: AppDelegate
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \UploadHistory.timestamp, ascending: false)],
        animation: .default)
    private var uploadHistoryItems: FetchedResults<UploadHistory>
    
    private var recentUploadItemsCount = 5
    
    init() {
        Theme.navigationBarStyle()
    }
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    EnrollmentDetailsView()
                    if (!appDelegate.sensorsAuthorized) {
                        SensorListView()
                    } else if (!uploadHistoryItems.isEmpty) {
                        Section(header: Text("Recent Uploads")) {
                            ForEach(uploadHistoryItems.prefix(recentUploadItemsCount)) { item in
                                NavigationLink (destination: UploadStatItemView(timestamp: item.timestamp!, data: item.data!)) {
                                    Text(item.timestamp!, formatter: dateFormatter)
                                }
                            }
                            
                            if (uploadHistoryItems.count > recentUploadItemsCount) {
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        
                                    } label: {
                                        Text("View More")
                                            .foregroundColor(.white)
                                            .padding([.bottom, .top], 10)
                                            .padding([.leading, .trailing], 20)
                                            
                                    }
                                    .background(Color.primaryPurple)
                                    .cornerRadius(8)
                                }
                                .padding([.top, .bottom], 10)
                            }
                        }
                    }
                    
                }.listStyle(.insetGrouped)
            }
            .navigationTitle("Chronicle")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await viewModel.fetchStudySensors()
            }
        }
    }
}

struct ProgressIndicatorView: View {
    let text: String
    var body: some View {
        HStack {
            Spacer()
            Text(text)
                .font(.body)
                .foregroundColor(.gray)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            Spacer()
        }
    }
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct EnrolledView_Previews: PreviewProvider {
    static var previews: some View {
        EnrolledView()
        ProgressIndicatorView(text: "In progress")
    }
}
