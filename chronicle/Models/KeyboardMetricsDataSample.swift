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
    let totalSpaceCorrections: Int
    let totalTypingDuration: Double
    let totalHitTestCorrections: Int // hit test correctiosn for the keyboard
    let totalSubstitutionCorrections: Int
    let totalNearKeyCorrections: Int // near key corrections
    let totalSkipTouchCorrections: Int //
    let totalInsertKeyCorrections: Int
    let totalTranspositionCorrections: Int
    let totalRetroCorrections: Int
    let totalAutoCorrections: Int
    let totalPaths: Int // total number of completed paths for keyboard
    let totalPathTime : Double // time to complete paths for the keyboard
    let emojiCountBySentiment: [String: Int] //number of typed emojis for specified sentiment
    let wordCountBySentiment: [String: Int] // number of typed words for specified sentiment
}
