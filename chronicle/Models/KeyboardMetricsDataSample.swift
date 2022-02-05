//
//  KeyboardMetricsDataSample.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/31/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation

// encapsulates data sample from keyboardMetrics sensor
// ref: https://developer.apple.com/documentation/sensorkit/srkeyboardmetrics
// NOTE: this properties are not exhaustive, might expand in future to include other data e.g probability metrics depending on need
struct KeyboardMetricsDataSample: Codable {
    let totalWords: Int
    let totalAlteredWords: Int
    let totalTaps: Int
    let totalDrags: Int
    let totalDeletes: Int
    let totalEmojis: Int
    let totalPaths: Int // total number of completed paths for keyboard
    let totalPathTime : Double // time to complete paths for the keyboard
    let totalPathLength: Double //units in cm
    let totalAutoCorrections: Int
    let totalSpaceCorrections: Int
    let totalRetroCorrections: Int
    let totalTranspositionCorrections: Int
    let totalInsertKeyCorrections: Int
    let totalSkipTouchCorrections: Int //
    let totalNearKeyCorrections: Int // near key corrections
    let totalSubstitutionCorrections: Int
    let totalHitTestCorrections: Int // hit test correctiosn for the keyboard
    let totalTypingDuration: Double
    var totalPathPauses: Int?
    var totalPauses: Int?
    var totalTypingEpisodes: Int?
    var pathTypingSpeed: Double? // QuickWords per minute
    var typingSpeed: Double? // typing rate in characters per second
    let emojiCountBySentiment: [String: Int] //number of typed emojis for specified sentiment
    let wordCountBySentiment: [String: Int] // number of typed words for specified sentiment
}
