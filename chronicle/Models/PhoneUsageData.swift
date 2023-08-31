//
//  PhoneUsageData.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/31/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import Foundation

// encapsulates data sample from phoneUsageReport sensor
// ref: https://developer.apple.com/documentation/sensorkit/srphoneusagereport

struct PhoneUsageData: Codable {
    let totalIncomingCalls: Int
    let totalOutgoingCalls: Int
    let totalPhoneDuration: Double
    let totalUniqueContacts: Int
}
