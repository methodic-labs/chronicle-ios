//
//  DeviceUsageDataSample.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/31/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation

// encapsulates sample data from deviceUsageReport sensor
// ref: https://developer.apple.com/documentation/sensorkit/srdeviceusagereport
struct DeviceUsageDataSample: Codable {
    let totalScreenWakes: Int // total number of screen wakes
    let totalUnlocks: Int // total number of device unlocks
    let totalUnlockDuration: Double // duration of time device is in unlocked state
    let appUsage: [String: [AppUsage]] // app category -> usages
    let webUsage: [String: Double] // category -> total usage time
    let notificationUsage: [String: [NotificationUsage]]
    let device: SensorReaderDevice // this could be an iOS or watchOS device
}

// struct encapsulates applicationusage data from deviceUsageReport sensor
struct AppUsage: Codable {
    let usageTime: Double
    let textInputSessions: [String: Double] // input source -> duration in seconds
    let bundleIdentifer: String
}


// encapsulate notification usage in a deviceUsageReport sample
// ref: https://developer.apple.com/documentation/sensorkit/srdeviceusagereport/notificationusage
struct NotificationUsage: Codable {
    let bundleIdentifier: String
    let event: String
}
