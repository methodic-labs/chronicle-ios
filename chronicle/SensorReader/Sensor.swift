//
//  Sensor.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit

enum Sensor: String, CaseIterable {
    case deviceUsage
    case phoneUsage
    case messagesUsage
    case keyboardMetrics
}

extension Sensor {
    static func getSensorName(sensor: SRSensor) -> String {
        switch(sensor) {
        case.deviceUsageReport:
            return Self.deviceUsage.rawValue
        case .phoneUsageReport:
            return Self.phoneUsage.rawValue
            
        case .messagesUsageReport:
            return Self.messagesUsage.rawValue
            
        case .keyboardMetrics:
            return Self.keyboardMetrics.rawValue
        default:
            return "unknown"
        }
    }
}
