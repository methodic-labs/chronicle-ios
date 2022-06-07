//
//  UploadStatEvent.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 3/17/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation

struct UploadStatEvent: Codable, Identifiable {
    var id: UUID
    var timestamp: Date
    var sensorType: String
    var samples: Int
    
    init(timestamp: Date, sensorType: String, samples: Int) {
        self.timestamp = timestamp
        self.sensorType = sensorType
        self.samples = samples
        self.id = UUID.init()
    }
}

extension UploadStatEvent {
    static var preview: [String : UploadStatEvent] {
        var data: [String : UploadStatEvent] = [:]
        Sensor.allCases.forEach { sensor in
            data[sensor.rawValue] = UploadStatEvent(timestamp: Date(), sensorType: sensor.rawValue, samples: 34)
        }
        return data
    }
}
