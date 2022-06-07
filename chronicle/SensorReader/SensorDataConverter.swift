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
        
        let data = PhoneUsageData(
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
        
        let data = MessagesUsageData(
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
            let key = category.localizedString()
            
            var appUsageArr: [AppUsage] = []
            appUsages.forEach {
                var textInput: [String: Double] = [:]
                var bundleIdentifier = $0.bundleIdentifier
                if #available(iOS 15.0, *) {
                    textInput = $0.textInputSessions.reduce(into: [String: Double]()) { result, session in
                        result[session.sessionType.toLocalizedString()] = session.duration
                    }
                    
                    if (bundleIdentifier == nil) {
                        bundleIdentifier = $0.reportApplicationIdentifier // only available in iOS15.0+
                    }
                }
                appUsageArr.append(AppUsage(usageTime: $0.usageTime, textInputSessions: textInput, bundleIdentifier: bundleIdentifier ?? ""))
            }
            appUsage[key] = appUsageArr
        }
        
        // web usage
        var webUsage: [String: Double] = [:]
        for (category, webUsageEntries) in sample.webUsageByCategory {
            let duration = webUsageEntries.reduce(0, { resultSoFar, usage in
                resultSoFar + usage.totalUsageTime
            })
            webUsage[category.localizedString()] = duration
        }
        
        let data = DeviceUsageData(
            totalScreenWakes: sample.totalScreenWakes,
            totalUnlocks: sample.totalUnlocks,
            totalUnlockDuration: sample.totalUnlockDuration,
            appUsage: appUsage,
            webUsage: webUsage
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
                $0[$1.toLocalizedString()] = sample.wordCount(for: $1)
            }.filter {
                $0.value != 0
            }
            
            emojiCountBySentiment = sentiments.reduce(into: [String: Int]()) {
                $0[$1.toLocalizedString()] = sample.wordCount(for: $1)
            }.filter {
                $0.value != 0
            }
        }
        var data = KeyboardMetricsData(
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
    func toLocalizedString() -> String {
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

@available(iOS 15.0, *)
extension SRKeyboardMetrics.SentimentCategory {
    func toLocalizedString() -> String {
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

extension SRDeviceUsageReport.CategoryKey {
    func localizedString() -> String {
        switch(self) {
        case .books:
            return "books"
        case .business:
            return "business"
        case .catalogs:
            return "catalogs"
        case .developerTools:
            return "developerTools"
        case .education:
            return "education"
        case .entertainment:
            return "entertainment"
        case .finance:
            return "finance"
        case .foodAndDrink:
            return "foodAndDrink"
        case .games:
            return "games"
        case .graphicsAndDesign:
            return "graphicsAndDesign"
        case .healthAndFitness:
            return "healthAndFitness"
        case .kids:
            return "kids"
        case .lifestyle:
            return "lifestyle"
        case .medical:
            return "medical"
        case .miscellaneous:
            return "miscellaneous"
        case .music:
            return "music"
        case .navigation:
            return "navigation"
        case .news:
            return "news"
        case .newsstand: // category for Apple News
            return "newsstand"
        case .photoAndVideo:
            return "photoAndVideo"
        case .productivity:
            return "productivity"
        case .reference:
            return "reference"
        case .shopping:
            return "shopping"
        case .socialNetworking:
            return "socialNetworking"
        case .sports:
            return "sports"
        case .stickers:
            return "stickers"
        case .travel:
            return "travel"
        case .utilities:
            return "utilities"
        case .weather:
            return "weather"
        default:
            return "unknown"
        }
    }
}
