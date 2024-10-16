//
//  AnalyticEvent.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 10/23/22.
//  Copyright © 2022 Methodic, Inc. All rights reserved.
//

import Foundation

// Event names to use with FirebaseAnalytics.
enum FirebaseAnalyticsEvent: String {
    case backgroundStartFetch // backround refresh handler for fetching sensor data
    case backgroundStartUpload // backround refresh handler for uploading data
    case backgroundHealthTaskRegistrationFailed // background health task registration for fetching sensor data failed
    case backgroundHealthTaskFetchFailed // Background fetch handler for requesting sensor data.
    case didFetchSensorDevices // SensorReaderDelegate didFetch callback
    case didFetchSensorSample // SensorReaderDelegate didFetchResult callback
    case fetchSensorSampleFailedError // failed while fetching sensor samples with sensorkit reported error
    case fetchSensorSampleFailedUnknownType // failed while fetching sensor samples
    case fetchSensorSampleFailedPersistenceController // failed while fetching sensor samples
    case uploadData // successfully persist data to server
    case uploadDataFailure
    case didHealthKitStepCountObserverFire //
    case didAppWakeUpForBackgroundFetch
    case didFetchFromCoreData
}
