//
//  Mocks.swift
//  Mocks
//
//  Created by Alfonce Nzioka on 11/16/21.
//

import Foundation
import OSLog

struct SensorDataMock {
    
    static var variablePTID = PropertyTypeIds.variablePTID
    static var valuesPTID = PropertyTypeIds.valuesPTID
    
    static func createMockData(sensorType: SensorType) -> Data {
        switch sensorType {
        case .visits:
            return createVisitsSensorMockData()
        case .deviceUsage:
            return createDeviceUsageSensorMockData()
        }
    }
    
    // mock data on user's travel routine: https://developer.apple.com/documentation/sensorkit/srvisit
    static func createVisitsSensorMockData() ->  Data {
        
        let locationCategories = ["gym", "home", "school", "work", "unknown"]
        let now = Date()
        let end = now + 4 * 60 * 60
        let arrivalStart = Date.randomBetween(start: now, end: now + 60 * 60)
        let arrivalEnd = Date.randomBetween(start: arrivalStart, end: now + 60 * 60)
        let departureStart = Date.randomBetween(start: end, end: end + 60 * 60)
        let departureEnd = Date.randomBetween(start: departureStart, end: departureStart + 60 * 60)
        
        let data = [
            [variablePTID: "distanceFromHome", valuesPTID: String(13222)],
            [variablePTID: "arrivalDateIntervalStart", valuesPTID: arrivalStart.toISOFormat()],
            [variablePTID: "arrivalDateIntervalEnd", valuesPTID: arrivalEnd.toISOFormat()],
            [variablePTID: "departureDateIntervalStart", valuesPTID: departureStart.toISOFormat()],
            [variablePTID: "departureDateIntervalEnd", valuesPTID: departureEnd.toISOFormat()],
            [variablePTID: "locationCategory", valuesPTID: locationCategories.randomElement()!]
        ]
        
        return try! JSONSerialization.data(withJSONObject: data, options: [])
    }
    
    //mock data on user's device usage: https://developer.apple.com/documentation/sensorkit/srdeviceusagereport
    static func createDeviceUsageSensorMockData() -> Data {
        let now = Date()
        let data = [
            [variablePTID: "intervalStart", valuesPTID: now.toISOFormat()],
            [variablePTID: "intervalEnd", valuesPTID: Date.randomBetween(start: now + 60 * 60, end: now + 60 * 60 * 5).toISOFormat()],
            [variablePTID: "totalScreenWakes", valuesPTID: String(10)],
            [variablePTID: "totalUnlocks", valuesPTID: String(5)],
        ]
        
        return try! JSONSerialization.data(withJSONObject: data, options: [])
    }
}


enum SensorType: String, CaseIterable {
    case visits
    case deviceUsage
}

// This will be replaced by values from an API call to the edm endpoint

struct PropertyTypeIds {
    static var variablePTID = "f3c1a844-8c32-4d7a-b18f-68d4cc031daf"
    static var valuesPTID = "dcc3bc24-3a5d-45cf-8e38-bc9ba8c43d06"
    static var endDateTimePTID = "0ee3acba-51a7-4f8d-921f-e23d75b07f65"
    static var startDateTime = "92a6a5c5-b4f1-40ce-ace9-be232acdce2a"
    static var idPTID = "39e13db7-a730-421a-a600-ae0674060140"
    static var namePTID = "ddb5d841-4c82-407c-8fcb-58f04ffc20fe"
    static var dateLoggedPTID = "e90a306c-ee37-4cd1-8a0e-71ad5a180340"
}
