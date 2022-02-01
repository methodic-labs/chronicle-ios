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
        let data = DeviceUsageDataSample(
            totalScreenWakes: 30,
            totalUnlocks: 20,
            totalUnlockDuration: 235.9,
            appUsage: [
                "books": [
                    AppUsage(
                        usageTime: 223.9,
                        textInputSessions: ["keyboard": 89, "pencil": 423],
                        bundleIdentifer: randomString(length: 5))]
            ],
            webUsage: ["catalogs": 9202.0],
            notificationUsage: [
                "education": [
                    NotificationUsage(bundleIdentifier: randomString(length: 9), event: "clear"),
                    NotificationUsage(bundleIdentifier: randomString(length: 7), event: "expired")
                ],
                "finance": [
                    NotificationUsage(bundleIdentifier: randomString(length: 4), event: "hide")
                ]
            ]
        )
        
        return try? JSONEncoder().encode(data)
    }
    
    private static func mockKeyboardMetricsData() -> Data? {
        let data = KeyboardMetricsDataSample(
            totalWords: 34,
            totalAlteredWords: 98,
            totalTaps: 93,
            totalDrags: 379,
            totalDeletes: 392,
            totalEmojis: 90,
            totalSpaceCorrections: 0,
            totalTypingDuration: 0,
            totalHitTestCorrections: 0,
            totalSubstitutionCorrections: 893,
            totalNearKeyCorrections: 039,
            totalSkipTouchCorrections: 0920,
            totalInsertKeyCorrections: 20,
            totalTranspositionCorrections: 2,
            totalRetroCorrections: 89,
            totalAutoCorrections: 9,
            totalPaths: 90,
            totalPathTime: 92,
            emojiCountBySentiment: ["angry": 45, "happy": 77],
            wordCountBySentiment: ["down": 89, "excited": 93]
        )
        
        return try? JSONEncoder().encode(data)
    }
    
    private static func mockMessagesUsageData() -> Data? {
        let data = MessagesUsageDataSample(totalIncomingMessages: 34, totalOutgoingMessages: 98, totalUniqueContacts: 4)
        return try? JSONEncoder().encode(data)
    }
    
    private static func mockPhoneUsageData() -> Data? {
        let data = PhoneUsageDataSample(totalIncomingCalls: 3, totalOutgoingCalls: 10, totalPhoneDuration: 600.9, totalUniqueContacts: 5)
        
        return try? JSONEncoder().encode(data)
    }
    
    static func mockSensorDataSample(sensor: Sensor) -> SensorDataProperties {
        
        let device = SensorReaderDevice(model: "iPhone", name: "user iPhone", systemName: "iOS", systemVersion: "15.4")
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
        }
        
        return SensorDataProperties(sensor: sensor, duration: 2423.9, writeTimeStamp: SRAbsoluteTime(rawValue: 15413910.591), data: data, device: device)
    }
}
