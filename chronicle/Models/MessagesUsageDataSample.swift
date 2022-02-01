//
//  MessagesUsageDataSample.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/31/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation

// encapsulate sample from messagesUsageReport sensor
// ref: https://developer.apple.com/documentation/sensorkit/srmessagesusagereport
struct MessagesUsageDataSample: Codable {
    let totalIncomingMessages: Int
    let totalOutgoingMessages: Int
    let totalUniqueContacts: Int
}
