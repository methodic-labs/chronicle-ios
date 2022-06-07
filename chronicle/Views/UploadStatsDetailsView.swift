//
//  UploadStatsDetailsView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 3/17/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import SwiftUI

struct UploadStatsDetailsView: View {
    var stats: [UploadStatEvent]
    
    init(data: Data) {
        let dict = try? JSONDecoder().decode([String?: UploadStatEvent].self, from: data)
        let emptyDict = Dictionary<String?, UploadStatEvent>()
        self.stats = Array(dict?.values ?? emptyDict.values)
    }
    
    var body: some View {
        VStack () {
            ForEach(stats) { item in
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(Sensor.init(rawValue: item.sensorType)!.localizedDescription)")
                        Spacer()
                    }
                    HStack {
                        Text("\(item.samples) samples")
                            .foregroundColor(.black.opacity(0.5))
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .background(Color.black.opacity(0.08))
    }
}



struct CardView: View {
    var content: UploadStatEvent
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 5) {
                Text("Data Type:")
                    .fontWeight(.semibold)
                Text("\(Sensor.init(rawValue: content.sensorType)!.localizedDescription)")
                Spacer()
            }
            HStack (spacing: 5) {
                Text("Samples:")
                    .fontWeight(.semibold)
                Text("\(content.samples)")
            }
        }.padding(10)
    }
}



struct UploadStatItemView_Previews: PreviewProvider {
    static var previews: some View {
        UploadStatsDetailsView(data: try! JSONEncoder().encode(UploadStatEvent.preview))
    }
}
