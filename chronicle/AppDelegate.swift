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
import SensorKit

/*
 The app delegate submits task requests and registers launch handlers for database background tasks
 */
class AppDelegate: NSObject, UIApplicationDelegate {
    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "AppDelegate")

    // task identifiers in BGTaskSchedulerPermittedIdentifiers array of Info.Plist
    let fetchSamplesTaskIdentifer = "com.openlattice.chronicle.fetchSensorSamples"
    let uploadDataTaskIdentifier = "com.openlattice.chronicle.uploadData"

    var uploadBackgroundTaskId: UIBackgroundTaskIdentifier?
    var importDataTaskId: UIBackgroundTaskIdentifier? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // register handlers for background tasks
        BGTaskScheduler.shared.register(forTaskWithIdentifier: uploadDataTaskIdentifier, using: nil) { task in
            // Downncast parameter to background refresh task
            self.handleUploadDataTask(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: fetchSamplesTaskIdentifer, using: nil) { task in
            self.handleFetchSensorSamples(task: task as! BGAppRefreshTask)
        }
        
        return true
    }
    
    // task handler to fetch data from sensor kit when app is in background
    func handleFetchSensorSamples(task: BGAppRefreshTask) {
        scheduleAppRefreshTask(delay: 15 * 60, taskIdentifer: fetchSamplesTaskIdentifer)
        
        fetchSensorSamples()
        
        task.setTaskCompleted(success: true)
    }

    func handleUploadDataTask(task: BGAppRefreshTask) {
        scheduleAppRefreshTask(delay: 15 * 60, taskIdentifer: uploadDataTaskIdentifier) // execute after 15 min
        
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
    func scheduleAppRefreshTask(delay: Double = 0, taskIdentifer: String) {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifer)
        request.earliestBeginDate = Date(timeIntervalSinceNow: delay) // no earlier than 15 min from now

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

            // terminate the task
            UIApplication.shared.endBackgroundTask(self.uploadBackgroundTaskId!)
            self.uploadBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
        }

        uploadOperation.start()
    }
    
    func fetchSensorSamples() {
        let sensors = SensorReaderDelegate.availableSensors
        sensors.forEach { sensor in
            let reader = SRSensorReader(sensor: sensor)
            reader.delegate = SensorReaderDelegate.shared
            
            if reader.authorizationStatus == SRAuthorizationStatus.authorized {
                reader.fetchDevices()
            }
        }
    }
    
    // Displays a prompt to request user to authorize sensors
    // If authorization has already been granted, no prompt is displayed
    func requestSensorReaderAuthorization() {
        let sensors = SensorReaderDelegate.availableSensors
        
        SRSensorReader.requestAuthorization(sensors: sensors ) { (error: Error?) -> Void in
            if let error = error {
                self.logger.info("Authorization failed: \(error.localizedDescription)")
            }
            
            sensors.forEach { sensor in
                let reader = SRSensorReader(sensor: sensor)
                
                if reader.authorizationStatus == SRAuthorizationStatus.authorized {
                    reader.delegate = SensorReaderDelegate.shared
                    reader.startRecording()
                    
                    Utils.saveInitialLastFetch(sensor: Sensor.getSensor(sensor: sensor))
                }
            }
        }
    }
}
