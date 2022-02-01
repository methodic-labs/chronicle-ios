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
    let importDataTaskIdentifier = "com.openlattice.chronicle.importSensorData"
    let uploadDataTaskIdentifier = "com.openlattice.chronicle.uploadData"

    var uploadBackgroundTaskId: UIBackgroundTaskIdentifier?
    var importDataTaskId: UIBackgroundTaskIdentifier? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // register handlers for background tasks
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
            logger.error("unable to execute upload task")
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
    
    // imports sensor data into core data
    func importIntoCoreData(data: SensorDataProperties) {
        self.importDataTaskId = UIApplication.shared.beginBackgroundTask(withName: "Import sensor sample to core data") {
            UIApplication.shared.endBackgroundTask(self.importDataTaskId!)
            self.importDataTaskId = nil
        }
        
        guard let context = PersistenceController.shared.newBackgroundContext() else {
            logger.error("unable to import sensor sample into core data. Exiting")
            return
        }
        
        let operation = UploadDataOperation(context: context)
        operation.completionBlock = {
            UIApplication.shared.endBackgroundTask(self.importDataTaskId!)
            self.importDataTaskId = nil
        }
        
        operation.start()
    }
}
