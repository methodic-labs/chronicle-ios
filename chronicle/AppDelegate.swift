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
    let uploadDataTaskIdentifier = "com.openlattice.chronicle.uploadData"

    var uploadBackgroundTaskId: UIBackgroundTaskIdentifier?
    var mockDataTaskId: UIBackgroundTaskIdentifier? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // register handlers for tasks
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: mockDataTaskIdentifer, using: nil) { task in
//            //Downcast parameter to a background refresh task
//            self.handleMockDataBackgroundTask(task: task as! BGAppRefreshTask)
//        }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: uploadDataTaskIdentifier, using: nil) { task in
            // Downncast parameter to background refresh task
            self.handleUploadDataTask(task: task as! BGAppRefreshTask)
        }

        return true
    }

    func handleUploadDataTask(task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.info("unable to execute upload task")
            task.setTaskCompleted(success: false)
            return
        }

        // operation to fetch data from database and upload to server
        let uploadDataOperation = UploadDataOperation(context: context)

        // expiration handler to cancel operation
        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        // inform system that task is complete
        uploadDataOperation.completionBlock = {
            task.setTaskCompleted(success: !uploadDataOperation.isCancelled)
        }

        // start operation
        queue.addOperation(uploadDataOperation)

    }

//    func handleMockDataBackgroundTask(task: BGAppRefreshTask) {
//        // schedule a new task
//        scheduleMockDataBackgroundTask()
//
//        let queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//
//        guard let context = PersistenceController.shared.newBackgroundContext() else {
//            logger.info("unable to execute task")
//            task.setTaskCompleted(success: true)
//            return
//        }
//
//        // operation to create fake sensor data and save to database
//        let mockDataOperation = MockSensorDataOperation(context: context)
//
//        // expiration handler to cancel operation
//        task.expirationHandler = {
//            queue.cancelAllOperations()
//        }
//
//        // inform system that task is complete
//        mockDataOperation.completionBlock = {
//            task.setTaskCompleted(success: !mockDataOperation.isCancelled)
//        }
//
//        // start the operation
//        queue.addOperation(mockDataOperation)
//    }

    // called when app moves to the background to schedule a task to be handled by handleMockDataBackgroundTask()
    func scheduleMockDataBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: mockDataTaskIdentifer)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // no earlier than 15minutes from now

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.info("Could not schedule mocking sensor data task: \(error.localizedDescription)")
        }
    }

    // called when app moves to background to schedule task handled by handleUploadDataTask
    func scheduleUploadDataBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: uploadDataTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // no earlier than 15 min from now

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.info("could not schedule task to upload data: \(error.localizedDescription)")
        }
    }

    // This method is invoked to trigger a single MockSensorData operation.
//    @objc func mockSensorData() {
//        // create backround context
//        guard let context = PersistenceController.shared.newBackgroundContext() else {
//            logger.info("unable to execute task")
//            return
//        }
//
//        // request additional background execution in case app goes to background
//        self.mockDataTaskId = UIApplication.shared.beginBackgroundTask(withName: "Create mock sensor data") {
//            // end task if time expires
//            UIApplication.shared.endBackgroundTask(self.mockDataTaskId!)
//            self.mockDataTaskId = UIBackgroundTaskIdentifier.invalid
//        }
//
//        let mockDataOperation = MockSensorDataOperation(context: context)
//        mockDataOperation.completionBlock = {
//            // end task after operation is completed
//            UIApplication.shared.endBackgroundTask(self.mockDataTaskId!)
//            self.mockDataTaskId = UIBackgroundTaskIdentifier.invalid
//        }
//
//        mockDataOperation.start()
//    }

    // invoked on a repeated schedule as long as EnrolledView is visible. This may take a long time, therefore we need to request for extended
    //  execution time before the app moves to the background
    @objc func uploadSensorData() {
        self.uploadBackgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "Finish uploading data to server") {
            // end the task if time expires
            UIApplication.shared.endBackgroundTask(self.uploadBackgroundTaskId!)
            self.uploadBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
        }

        // create backround context
        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.info("unable to execute upload task")
            UIApplication.shared.endBackgroundTask(self.uploadBackgroundTaskId!)
            self.uploadBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
            return
        }

        // operation to upload data
        let uploadOperation = UploadDataOperation(context: context)
        uploadOperation.completionBlock = {
            // end the task
            UIApplication.shared.endBackgroundTask(self.uploadBackgroundTaskId!)
            self.uploadBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
        }

        uploadOperation.start()
    }
    
    func importIntoCoreData(data: SensorDataProperties) {
        
    }
}
