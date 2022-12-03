//
//  AnalyticEvent.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 10/23/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation

// Event names to use with FirebaseAnalytics.
enum FirebaseAnalyticsEvent: String {
    case backgroundStartFetch // backround refresh handler for fetching sensor data
    case backgroundStartUpload // backround refresh handler for uploading data
    case didFetchSensorDevices // SensorReaderDelegate didFetch callback
    case didFetchSensorSample // SensorReaderDelegate didFetchResult callback
    case uploadData // successfully persist data to server
    case uploadDataFailure
    case didAppWakeUpForBackgroundFetch
}
