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
    
    // task identifiers in BGTaskSchedulerPermittedIdentifiers array of Info.Plist
    let mockDataTaskIdentifer = "com.openlattice.chronicle.mockSensorData"
    
    var mockDataTaskId: UIBackgroundTaskIdentifier? = nil
    

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
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.info("unable to execute task")
            task.setTaskCompleted(success: true)
            return
        }
        
        // operation to create fake sensor data and save to database
        let mockDataOperation = MockSensorDataOperation(context: context)
        
        // expiration handler to cancel operation
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        // inform system that task is complete
        mockDataOperation.completionBlock = {
            task.setTaskCompleted(success: !mockDataOperation.isCancelled)
        }
        
        // start the operation
        queue.addOperation(mockDataOperation)
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
    
    // This method is invoked to trigger a single MockSensorData operation.
    @objc func mockSensorData() {
        // create backround context
        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.info("unable to execute task")
            return
        }
        
        // request additional background execution in case app goes to background
        self.mockDataTaskId = UIApplication.shared.beginBackgroundTask(withName: "Create mock sensor data") {
            // end task if time expires
            UIApplication.shared.endBackgroundTask(self.mockDataTaskId!)
            self.mockDataTaskId = UIBackgroundTaskIdentifier.invalid
        }
        
        let mockDataOperation = MockSensorDataOperation(context: context)
        mockDataOperation.completionBlock = {
            // end task after operation is completed
            UIApplication.shared.endBackgroundTask(self.mockDataTaskId!)
            self.mockDataTaskId = UIBackgroundTaskIdentifier.invalid
        }
        
        mockDataOperation.start()
    }
}
