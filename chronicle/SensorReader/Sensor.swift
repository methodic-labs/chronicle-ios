//
//  Sensor.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import Foundation
import SensorKit

enum Sensor: String, CaseIterable, Codable {
    case deviceUsage
    case phoneUsage
    case messagesUsage
    case keyboardMetrics
    
    var localizedDescription: String {
        switch self {
        case .phoneUsage:
            return "Phone Usage"
        case .deviceUsage:
            return "Device Usage"
        case .messagesUsage:
            return "Messages Usage"
        case .keyboardMetrics:
            return "Keyboard Metrics"
        }
    }
}

extension Sensor {
    static func getSensor(sensor: SRSensor) -> Self? {
        switch(sensor) {
        case.deviceUsageReport:
            return Self.deviceUsage
            
        case .phoneUsageReport:
            return Self.phoneUsage
            
        case .messagesUsageReport:
            return Self.messagesUsage
            
        case .keyboardMetrics:
            return Self.keyboardMetrics
        default:
            return nil
        }
    }
    
    static func getSRSensor(sensor: Self) -> SRSensor? {
        switch (sensor) {
        case .phoneUsage:
            return .phoneUsageReport
        case .keyboardMetrics:
            return .keyboardMetrics
        case .deviceUsage:
            return .deviceUsageReport
        case .messagesUsage:
            return .messagesUsageReport
        }
    }
}
