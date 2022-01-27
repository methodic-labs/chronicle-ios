//
//  SensorReaderDelegate.swift
//  chronicle
//
//  Created by Alfonce Nzioka on 1/27/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import Foundation
import SensorKit
import OSLog

/**
  This class responds to sensor-related events
 */
class SensorReaderDelegate: NSObject, SRSensorReaderDelegate {
    private let appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }
    private let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorReader")
    
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        logger.info("started recording \(reader.sensor.rawValue)")
    }
    
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        logger.info("stopped recording \(reader.sensor.rawValue)")
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        
        return true
    }
}
