//
//  SensorDataConverter.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit

// This struct contains utility methods for converting SRSensor sample data to a format that is compatible to our core data model
struct SensorDataConverter {
    static func getPhoneUsageData(sample: SRPhoneUsageReport, timestamp: SRAbsoluteTime, request: SRFetchRequest) -> SensorDataProperties {
        
        let data = PhoneUsageDataSample(
            totalIncomingCalls: sample.totalIncomingCalls,
            totalOutgoingCalls: sample.totalOutgoingCalls,
            totalPhoneDuration: sample.totalPhoneCallDuration,
            totalUniqueContacts: sample.totalUniqueContacts
        )
        
        return SensorDataProperties(
            sensor: Sensor.getSensor(sensor: .phoneUsageReport),
            duration: sample.duration,
            writeTimeStamp: timestamp,
            from: request.from,
            to: request.to,
            data: try? JSONEncoder().encode(data),
            device: try? JSONEncoder().encode(SensorReaderDevice(device: request.device))
            
        )
    }
    
    static func getMessagesData(sample: SRMessagesUsageReport, timestamp: SRAbsoluteTime, request: SRFetchRequest) -> SensorDataProperties {
        
        let data = MessagesUsageDataSample(
            totalIncomingMessages: sample.totalIncomingMessages,
            totalOutgoingMessages: sample.totalOutgoingMessages,
            totalUniqueContacts: sample.totalUniqueContacts
        )
        
        return SensorDataProperties(
            sensor: Sensor.getSensor(sensor: .messagesUsageReport),
            duration: sample.duration,
            writeTimeStamp: timestamp,
            from: request.from,
            to: request.to,
            data: try? JSONEncoder().encode(data),
            device: try? JSONEncoder().encode(SensorReaderDevice(device: request.device))
        )
    }
    
    static func getDeviceUsageData(sample: SRDeviceUsageReport, timestamp: SRAbsoluteTime, request: SRFetchRequest) -> SensorDataProperties {

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
                
        return SensorDataProperties(
            sensor: Sensor.getSensor(sensor: .deviceUsageReport),
            duration: sample.duration,
            writeTimeStamp: timestamp,
            from: request.from,
            to: request.to,
            data: try? JSONEncoder().encode(data),
            device: try? JSONEncoder().encode(SensorReaderDevice(device: request.device))
        )
    }
    
    static func getKeyboardMetricsData(sample: SRKeyboardMetrics, timestamp: SRAbsoluteTime, request: SRFetchRequest) -> SensorDataProperties {
        
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
        var data = KeyboardMetricsDataSample(
            totalWords: sample.totalWords,
            totalAlteredWords: sample.totalAlteredWords,
            totalTaps: sample.totalTaps,
            totalDrags: sample.totalDrags,
            totalDeletes: sample.totalDeletes,
            totalEmojis: sample.totalEmojis,
            totalPaths: sample.totalPaths,
            totalPathTime: sample.totalPathTime,
            totalPathLength: sample.totalPathLength.converted(to: UnitLength.centimeters).value,
            totalAutoCorrections: sample.totalAutoCorrections,
            totalSpaceCorrections: sample.totalSpaceCorrections,
            totalRetroCorrections: sample.totalRetroCorrections,
            totalTranspositionCorrections: sample.totalTranspositionCorrections,
            totalInsertKeyCorrections: sample.totalInsertKeyCorrections,
            totalSkipTouchCorrections: sample.totalSkipTouchCorrections,
            totalNearKeyCorrections: sample.totalNearKeyCorrections,
            totalSubstitutionCorrections: sample.totalSubstitutionCorrections,
            totalHitTestCorrections: sample.totalHitTestCorrections,
            totalTypingDuration: sample.totalTypingDuration,
            emojiCountBySentiment: emojiCountBySentiment,
            wordCountBySentiment: wordCountBySentiment
        )
        
        if #available(iOS 15.0, *) {
            data.totalPathPauses = sample.totalPathPauses
            data.typingSpeed = sample.typingSpeed
            data.pathTypingSpeed = sample.pathTypingSpeed
            data.totalTypingEpisodes = sample.totalTypingEpisodes
            data.totalPauses = sample.totalPauses
            data.totalPathPauses = sample.totalPathPauses
        }
        
        return SensorDataProperties(
            sensor: Sensor.getSensor(sensor: .keyboardMetrics),
            duration: sample.duration,
            writeTimeStamp: timestamp,
            from: request.from,
            to: request.to,
            data: try? JSONEncoder().encode(data),
            device: try? JSONEncoder().encode(SensorReaderDevice(device: request.device))
        )
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

