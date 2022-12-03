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
import FirebaseCore
import FirebaseAnalytics

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
        
        application.setMinimumBackgroundFetchInterval(15 * 60) // wake up app for background fetch every 15 minutes
        
        // Initialize firebase
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let enrollment = Enrollment.getCurrentEnrollment()
        guard enrollment.isValid else {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        
        fetchSensorSamples()
        uploadSensorData()

        Analytics.logEvent(FirebaseAnalyticsEvent.didAppWakeUpForBackgroundFetch.rawValue, parameters: enrollment.toDict())
        
        completionHandler(UIBackgroundFetchResult.newData)
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
