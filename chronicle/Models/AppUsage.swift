//
//  AppUsage.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/31/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation

// struct encapsulates applicationusage data from deviceUsageReport sensor
struct AppUsage: Codable {
    let usageTime: Double
    let textInputSessions: [String: Double]
    let bundleIdentifer: String
}
