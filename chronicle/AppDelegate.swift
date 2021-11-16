//
//  AppDelegate.swift
//  AppDelegate
//
//  Created by Alfonce Nzioka on 11/16/21.
//

import Foundation
import UIKit
import BackgroundTasks
import OSLog

/*
 The app delegate submits task requests and registers launch handlers for database background tasks
 */
class AppDelegate: NSObject, UIApplicationDelegate {
    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "AppDelegate")
    
    let mockDataTaskIdentifer = "com.openlattice.chronicle.mockSensorData"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // register handlers for tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: mockDataTaskIdentifer, using: nil) { task in
            //Downcast parameter to a background refresh task
            self.handleMockSensorData(task: task as! BGAppRefreshTask)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleMockSensorTask()
        
    }
    
    func handleMockSensorData(task: BGAppRefreshTask) {
        // schedule a new task
        scheduleMockSensorTask()
        
        
    }
    
    
    func scheduleMockSensorTask() {
        let request = BGAppRefreshTaskRequest(identifier: mockDataTaskIdentifer)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // no earlier than 15minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.info("Could not schedule mocking sensor data task: \(error.localizedDescription)")
        }
    }
}
