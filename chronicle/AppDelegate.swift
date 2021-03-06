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
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    
    @Published var authorizationError: Bool = false
    @Published var sensorsAuthorized: Bool = false
    
    override init() {
        super.init()
        self.sensorsAuthorized = UserDefaults.standard.object(forKey: UserSettingsKeys.sensorsAuthorized) as? Bool ?? false
    }
    
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

        guard let bgContext = PersistenceController.shared.newBackgroundContext() else {
            logger.error("unable to execute upload task")
            task.setTaskCompleted(success: false)
            return
        }
        
        guard let viewContext = PersistenceController.shared.persistentContainer?.viewContext else {
            return
        }

        // operation to fetch data from database and upload to server
        let uploadDataOperation = UploadDataOperation(bgContext: bgContext, viewContext: viewContext)

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

    // Attempts to upload locally stored data to server
    @objc func uploadSensorData() {
        //perform on a background queue
        DispatchQueue.global().async {
            self.uploadBackgroundTaskId = UIApplication.shared.beginBackgroundTask(withName: "Finish uploading data to server") {
                // end the task if time expires
                UIApplication.shared.endBackgroundTask(self.uploadBackgroundTaskId!)
                self.uploadBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
            }

            // create backround context
            guard let bgContext = PersistenceController.shared.newBackgroundContext() else {
                self.logger.info("unable to create upload task")
                UIApplication.shared.endBackgroundTask(self.uploadBackgroundTaskId!)
                self.uploadBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
                return
            }
            
            guard let viewContext = PersistenceController.shared.persistentContainer?.viewContext else {
                return
            }

            // operation to upload data
            let uploadOperation = UploadDataOperation(bgContext: bgContext, viewContext: viewContext)
            uploadOperation.completionBlock = {

                // terminate the task
                UIApplication.shared.endBackgroundTask(self.uploadBackgroundTaskId!)
                self.uploadBackgroundTaskId = UIBackgroundTaskIdentifier.invalid
            }

            uploadOperation.start()
        }

    }
    
    func fetchSensorSamples() {
        let sensors = SensorReaderDelegate.availableSensors
        sensors.forEach { sensor in
            let reader = SRSensorReader(sensor: sensor)
            reader.delegate = SensorReaderDelegate.shared
            
            if reader.authorizationStatus == SRAuthorizationStatus.authorized {
                reader.startRecording()
                reader.fetchDevices()
            }
        }
    }
    
    // Displays a prompt to request user to authorize sensors
    // If authorization has already been granted, no prompt is displayed
    func requestSensorReaderAuthorization(valid: [Sensor], invalid: [Sensor]) {
        let permittedSensors = Set(valid.map { Sensor.getSRSensor(sensor: $0)}.compactMap { $0 })
        let invalidSensors = Set(invalid.map { Sensor.getSRSensor(sensor: $0)}.compactMap { $0 })
        let allSensors = permittedSensors.union(invalidSensors)
        
        SRSensorReader.requestAuthorization(sensors: permittedSensors ) { (error: Error?) -> Void in
            if let error = error {
                self.authorizationError = true
                self.logger.info("Authorization failed: \(error.localizedDescription)")
            } else {
                self.sensorsAuthorized = true
                UserDefaults.standard.set(true, forKey: UserSettingsKeys.sensorsAuthorized)
            }
            
            allSensors.forEach { sensor in
                let reader = SRSensorReader(sensor: sensor)
                
                if reader.authorizationStatus == SRAuthorizationStatus.authorized {
                    self.sensorsAuthorized = true
                    UserDefaults.standard.set(true, forKey: UserSettingsKeys.sensorsAuthorized)
                    
                    reader.delegate = SensorReaderDelegate.shared
                    if (invalidSensors.contains(sensor)) {
                        reader.stopRecording()
                    } else {
                        reader.startRecording()
                        Utils.saveInitialLastFetch(sensor: Sensor.getSensor(sensor: sensor))
                    }
                }
            }
        }
    }
}
