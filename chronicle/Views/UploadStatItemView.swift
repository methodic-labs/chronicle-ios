//
//  UploadStatItemView.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 3/17/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import SwiftUI

struct UploadStatItemView: View {
    var timestamp: Date
    var stats: [UploadStatEvent]
    
    init(timestamp :Date, data: Data) {
        let dict = try? JSONDecoder().decode([String?: UploadStatEvent].self, from: data)
        let emptyDict = Dictionary<String?, UploadStatEvent>()
        self.stats = Array(dict?.values ?? emptyDict.values)
        self.timestamp = timestamp
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(timestamp, formatter: dateFormatter) Upload")
                .fontWeight(.bold)
                ForEach(stats) { item in
                    CardView(content: item)
                        .aspectRatio(contentMode: .fit)
                        
                }
            Spacer()
        }.padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
}



struct CardView: View {
    var content: UploadStatEvent
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 10)
            shape
                .fill()
                .foregroundColor(.white)
            shape
                .stroke(Color.gray, lineWidth: 1)
                
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Data Type:")
                        .fontWeight(.semibold)
                        .padding(.trailing, 1)
                    Text("\(Sensor.init(rawValue: content.sensorType)!.localizedDescription)")
                    Spacer()
                }
                HStack {
            
                    Text("Samples: ")
                        .fontWeight(.semibold)
                        .padding(.trailing, 1)
                    Text("\(content.samples)")
                }
            }.padding([.trailing, .leading], 10)
        }
    }
}



struct UploadStatItemView_Previews: PreviewProvider {
    static var previews: some View {
        UploadStatItemView(
            timestamp: Date(), data: try! JSONEncoder().encode(UploadStatEvent.preview)
        )
    }
}
