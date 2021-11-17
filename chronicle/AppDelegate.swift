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
    
    
    var saveDataBackroundTaskID: UIBackgroundTaskIdentifier?
    
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
    
    @objc func mockSensorData() {
        self.saveDataBackroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "Save mock data to database") {
            // end task if time expires
            UIApplication.shared.endBackgroundTask(self.saveDataBackroundTaskID!)
            self.saveDataBackroundTaskID = nil
            
        }
        
        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.info("unable to execute task")
            UIApplication.shared.endBackgroundTask(self.saveDataBackroundTaskID!)
            return
        }
        
        let saveDataOperation = MockSensorDataOperation(context: context)
        saveDataOperation.completionBlock = {
            UIApplication.shared.endBackgroundTask(self.saveDataBackroundTaskID!)
        }
        
        saveDataOperation.start()
    }
}
