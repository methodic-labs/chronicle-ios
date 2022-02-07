//
//  TestUtils.swift
//  chronicleTests
//
//  Created by Alfonce Nzioka on 2/1/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit


// util methods for unit tests

struct TestUtils {
    // Generating Random String
    private static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func mockDeviceUsageData() -> Data? {
        let data = DeviceUsageData(
            totalScreenWakes: 30,
            totalUnlocks: 20,
            totalUnlockDuration: 235.9,
            appUsage: [
                "books": [
                    AppUsage(
                        usageTime: 223.9,
                        textInputSessions: ["keyboard": 89, "pencil": 423],
                        bundleIdentifier: randomString(length: 5))]
            ],
            webUsage: ["catalogs": 9202.0]
        )
        
        return try? JSONEncoder().encode(data)
    }
    
    private static func mockKeyboardMetricsData() -> Data? {
        let data = KeyboardMetricsData(
            totalWords: 34,
            totalAlteredWords: 98,
            totalTaps: 93,
            totalDrags: 379,
            totalDeletes: 392,
            totalEmojis: 90,
            totalPaths: 90,
            totalPathTime: 92,
            totalPathLength: 203,
            totalAutoCorrections: 9,
            totalSpaceCorrections: 0,
            totalRetroCorrections: 89,
            totalTranspositionCorrections: 2,
            totalInsertKeyCorrections: 20,
            totalSkipTouchCorrections: 0920,
            totalNearKeyCorrections: 039,
            totalSubstitutionCorrections: 2,
            totalHitTestCorrections: 0,
            totalTypingDuration: 0,
            emojiCountBySentiment: ["angry": 45, "happy": 77],
            wordCountBySentiment: ["down": 89, "excited": 93]
        )
        
        return try? JSONEncoder().encode(data)
    }
    
    private static func mockMessagesUsageData() -> Data? {
        let data = MessagesUsageData(totalIncomingMessages: 34, totalOutgoingMessages: 98, totalUniqueContacts: 4)
        return try? JSONEncoder().encode(data)
    }
    
    private static func mockPhoneUsageData() -> Data? {
        let data = PhoneUsageData(totalIncomingCalls: 3, totalOutgoingCalls: 10, totalPhoneDuration: 600.9, totalUniqueContacts: 5)
        
        return try? JSONEncoder().encode(data)
    }
    
    static func mockSensorDataSample(sensor: Sensor) -> SensorDataProperties {
        let device = SensorReaderDevice(model: "iPhone", name: "test phone", systemName: "iOS", systemVersion: "15.4")
        
        var data: Data?
        
        switch (sensor) {
        case .keyboardMetrics:
            data = mockKeyboardMetricsData()
        case .deviceUsage:
            data = mockDeviceUsageData()
        case .messagesUsage:
            data = mockMessagesUsageData()
        case .phoneUsage:
            data = mockPhoneUsageData()
        default:
            break
        }
        
        return SensorDataProperties(
            sensor: sensor,
            duration: 2423.9,
            writeTimeStamp: SRAbsoluteTime(rawValue: 15413910.591),
            from: SRAbsoluteTime.init(rawValue: 283),
            to: SRAbsoluteTime.init(rawValue: 92392),
            data: data,
            device: try? JSONEncoder().encode(device)
        )
    }
}
