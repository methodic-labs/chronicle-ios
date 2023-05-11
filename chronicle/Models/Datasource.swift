//
//  Datasource.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 2/1/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import Foundation

//A JSON encodable struct which forms the request body of server request
struct Datasource: Codable {
    let id: UUID?
    let dateRecorded: String?
    let startDate: String?
    let endDate: String?
    let duration: Double?
    let data: String? // a stringified json representing all supported sensor sample types
    let device: String?
    let timezone: String?
    let sensor: String?
    
  
    init(source: SensorData) {
        self.id = source.id
        self.dateRecorded = source.writeTimestamp?.toISOFormat()
        self.duration = source.duration
        self.data = String(data: source.data ?? Data.init(), encoding: .utf8)
        self.timezone = source.timezone
        self.sensor = source.sensorType
        self.startDate = source.startDate?.toISOFormat()
        self.endDate = source.endDate?.toISOFormat()
        self.device = String(data: source.device ?? Data.init(), encoding: .utf8)
    }
    
    func isValidSource () -> Bool {
        return id != nil && dateRecorded != nil && data != nil && !(data?.isEmpty ?? true) && timezone != nil && sensor != nil
    }

    
    static func encodeArray(arr: [SensorData]) -> Data? {
        let objects = arr
            .map { Self(source: $0) }
            .filter {$0.isValidSource()}
        
        return try? JSONEncoder().encode(objects)
    }
}

