//
//  SensorDataConverter.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit

// This class contains utility methods for converting SRSensor sample data to a format that conforms to our core data model
struct SensorDataConverter {
    static var variablePTID = PropertyTypeIds.variablePTID
    static var valuesPTID = PropertyTypeIds.valuesPTID
    static var mapping = SensorReader.sensorNameMapping
    
    static func getPhoneUsageData(sample: SRPhoneUsageReport, timestamp: SRAbsoluteTime) -> SensorDataProperties {
        
        let data = PhoneUsageDataSample(
            totalIncomingCalls: sample.totalIncomingCalls,
            totalOutgoingCalls: sample.totalOutgoingCalls,
            totalPhoneDuration: sample.totalPhoneCallDuration,
            totalUniqueContacts: sample.totalUniqueContacts
        )
        let encoded = try? JSONEncoder().encode(data)
        
        return SensorDataProperties(sensor: mapping[.phoneUsageReport]!, duration: sample.duration, writeTimeStamp: timestamp, data: encoded)

    }
    
    static func getMessagesData(sample: SRMessagesUsageReport, timestamp: SRAbsoluteTime) -> SensorDataProperties {
        
        let data = MessagesUsageDataSample(
            totalIncomingMessages: sample.totalIncomingMessages,
            totalOutgoingMessages: sample.totalOutgoingMessages,
            totalUniqueContacts: sample.totalUniqueContacts
        )
        let encoded = try? JSONEncoder().encode(data)
        
        return SensorDataProperties(sensor: mapping[.messagesUsageReport]!, duration: sample.duration, writeTimeStamp: timestamp, data: encoded)
    }
    
    static func getDeviceUsageData(sample: SRDeviceUsageReport, timestamp: SRAbsoluteTime) -> SensorDataProperties {

        // application usage
        var appUsage: [String: [AppUsage]] = [:]
        
        for (category, appUsages) in sample.applicationUsageByCategory {
            let key = category.rawValue
            
            var appUsageArr: [AppUsage] = []
            appUsages.filter {
                $0.bundleIdentifier != nil
            }.forEach {
                var textInput: [String: Double] = [:]
                if #available(iOS 15.0, *) {
                    textInput = $0.textInputSessions.reduce(into: [String: Double]()) { result, session in
                        result[session.sessionType.toString()] = session.duration
                    }
                }
                appUsageArr.append(AppUsage(usageTime: $0.usageTime, textInputSessions: textInput, bundleIdentifer: $0.bundleIdentifier!)) // safe to force unwrap optional since we already filtered out entries where bundleIdenfier = nil
            }
            appUsage[key] = appUsageArr
        }
        
        // web usage
        var webUsage: [String: Double] = [:]
        for (category, webUsageEntries) in sample.webUsageByCategory {
            let duration = webUsageEntries.reduce(0, { resultSoFar, usage in
                resultSoFar + usage.totalUsageTime
            })
            webUsage[category.rawValue] = duration
        }
        
        // notification usage
        var notificationUsage: [String: [NotificationUsage]] = [:]
        for (category, notificationUsageEntries) in sample.notificationUsageByCategory {
            let events: [NotificationUsage] = notificationUsageEntries.filter {
                $0.bundleIdentifier != nil
            }.map {
                NotificationUsage(bundleIdentifier: $0.bundleIdentifier!, event: $0.event.toString())
            }
            notificationUsage[category.rawValue] = events
        }
        
        let data = DeviceUsageDataSample(
            totalScreenWakes: sample.totalScreenWakes,
            totalUnlocks: sample.totalUnlocks,
            totalUnlockDuration: sample.totalUnlockDuration,
            appUsage: appUsage,
            webUsage: webUsage,
            notificationUsage: notificationUsage
        )
        let encoded = try? JSONEncoder().encode(data)
        
        return SensorDataProperties(sensor: mapping[.deviceUsageReport]!, duration: sample.duration, writeTimeStamp: timestamp, data: encoded)
    }
    
    static func getKeyboardMetricsData(sample: SRKeyboardMetrics, timestamp: SRAbsoluteTime) -> SensorDataProperties {
        
        var wordCountBySentiment: [String: Int] = [:]
        var emojiCountBySentiment: [String: Int] = [:]
        
        if #available(iOS 15.0, *) {
            // hard coding this array here becuase SRKeyboardMetrics.SentimentCategory does not conform to CaseIterable protocol!!
            
            let sentiments: [SRKeyboardMetrics.SentimentCategory] = [
                .sad,
                .anger,
                .anxiety,
                .confused,
                .death,
                .down,
                .health,
                .lowEnergy,
                .positive,
                .sad
            ]
            wordCountBySentiment = sentiments.reduce(into: [String: Int]()) {
                $0[$1.toString()] = sample.wordCount(for: $1)
            }.filter {
                $0.value != 0
            }
            
            emojiCountBySentiment = sentiments.reduce(into: [String: Int]()) {
                $0[$1.toString()] = sample.wordCount(for: $1)
            }.filter {
                $0.value != 0
            }
        }
        let data = KeyboardMetricsDataSample(
            totalWords: sample.totalWords,
            totalAlteredWords: sample.totalAlteredWords,
            totalTaps: sample.totalTaps,
            totalDrags: sample.totalDrags,
            totalDeletes: sample.totalDeletes,
            totalEmojis: sample.totalEmojis,
            totalSpaceCorrections: sample.totalSpaceCorrections,
            totalTypingDuration: sample.totalTypingDuration,
            totalHitTestCorrections: sample.totalHitTestCorrections,
            totalSubstitutionCorrections: sample.totalSubstitutionCorrections,
            totalNearKeyCorrections: sample.totalNearKeyCorrections,
            totalSkipTouchCorrections: sample.totalSkipTouchCorrections,
            totalInsertKeyCorrections: sample.totalInsertKeyCorrections,
            totalTranspositionCorrections: sample.totalTranspositionCorrections,
            totalRetroCorrections: sample.totalRetroCorrections,
            totalAutoCorrections: sample.totalAutoCorrections,
            totalPaths: sample.totalPaths,
            totalPathTime: sample.totalPathTime,
            emojiCountBySentiment: emojiCountBySentiment,
            wordCountBySentiment: wordCountBySentiment)
        
        let encoded = try? JSONEncoder().encode(data)
        
        return SensorDataProperties(sensor: mapping[.keyboardMetrics]!, duration: sample.duration, writeTimeStamp: timestamp, data: encoded)
    }
}

@available(iOS 15.0, *)
extension SRTextInputSession.SessionType {
    func toString() -> String {
        switch (self) {
        case .keyboard:
            return "keyboard"
        case .thirdPartyKeyboard:
            return "thirdPartyKeyboard"
        case .pencil:
            return "pencil"
        case .dictation:
            return "dictation"
        default:
            return "unknown"
        }
    }
}

extension SRDeviceUsageReport.NotificationUsage.Event {
    func toString() -> String {
        switch (self) {
        case .deviceUnlocked:
            return "deviceUnlocked"
        case .appLaunch:
            return "appLaunch"
        case .bannerPulldown:
            return "bannerPullDown"
        case .clear:
            return "clear"
        case .deduped:
            return "deduped"
        case .defaultAction:
            return "defaultAction"
        case .deviceActivated:
            return "deviceActivated"
        case Self.expired:
            return "expired"
        case .hide:
            return "hide"
        case .longLook:
            return "longLook"
        case .notificationCenterClearAll:
            return "clearAll"
        case .received:
            return "received"
        case .removed:
            return "removed"
        case .silence:
            return "silence"
        case .supplementaryAction:
            return "supplimentaryAction"
        case .tapCoalesce:
            return "tapCoalesce"
        case .unknown:
            return "unknown"
        default:
            return "unknown"
        }
    }
}

@available(iOS 15.0, *)
extension SRKeyboardMetrics.SentimentCategory {
    func toString() -> String {
        switch (self) {
        case .absolutist:
            return "absolutist"
        case .anger:
            return "anger"
        case .anxiety:
            return "anxiety"
        case .confused:
            return "confused"
        case .death:
            return "death"
        case .down:
            return "down" // embodies depression
        case .health: // general concern for health
            return "health"
        case .lowEnergy:
            return "lowEnergy"
        case .positive:
            return "positive"
        case .sad:
            return "sad"
        default:
            return "unknown"
        }
    }
}

