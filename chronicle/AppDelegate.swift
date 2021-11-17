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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // register handlers for tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: mockDataTaskIdentifer, using: nil) { task in
            //Downcast parameter to a background refresh task
            self.handleMockSensorData(task: task as! BGAppRefreshTask)
        }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: uploadDataTaskIdentifier, using: nil) { task in
            // Downncast parameter to background refresh task
            self.handleUploadDataTask(task: task as! BGAppRefreshTask)
        }

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleMockSensorTask()
        scheduleUploadDataTask()
    }

    func handleUploadDataTask(task: BGAppRefreshTask) {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.info("unable to execute upload task")
            task.setTaskCompleted(success: false)
            return
        }

        let deviceId = UserDefaults.standard.object(forKey: UserSettingsKeys.deviceId) as? String ?? ""
        guard !deviceId.isEmpty else {
            logger.error("invalid deviceId")
            return
        }

        let enrollment = Enrollment.getCurrentEnrollment()
        guard enrollment.isValid else {
            logger.error("unable to retrieve enrollment details")
            return
        }

        // operation to fetch data from database and upload to server
        let uploadDataOperation = UploadDataOperation(context: context, deviceId: deviceId, enrollment: enrollment)

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

    func scheduleUploadDataTask() {
        let request = BGAppRefreshTaskRequest(identifier: uploadDataTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // no earlier than 15 min from now

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            logger.info("could not schedule task to upload data: \(error.localizedDescription)")
        }
    }

    // This method is called on a repeated schedule when EnrolledView loads. This will only execute as long as the app is in the foreground.
    @objc func mockSensorData() {
        // create backround context
        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.info("unable to execute task")
            return
        }

        let mockDataOperation = MockSensorDataOperation(context: context)

        mockDataOperation.start()
    }
}
