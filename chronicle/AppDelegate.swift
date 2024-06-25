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
import HealthKit
import FirebaseCore
import FirebaseAnalytics

/*
 The app delegate submits task requests and registers launch handlers for database background tasks
 */
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    @Published var authorizationError: Bool = false
    @Published var sensorsAuthorized: Bool = false
    @Published var healthKitAuthorized: Bool = false
    var healthStore: HKHealthStore?
    
    override init() {
        super.init()
        self.sensorsAuthorized = UserDefaults.standard.object(forKey: UserSettingsKeys.sensorsAuthorized) as? Bool ?? false
    }

    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "AppDelegate")

    var uploadBackgroundTaskId: UIBackgroundTaskIdentifier?
    var importDataTaskId: UIBackgroundTaskIdentifier? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        // Initialize firebase
        FirebaseApp.configure()
        
        application.setMinimumBackgroundFetchInterval(15 * 60) // background refresh every 15 minutes

        // Configure HealthKit
        if !HKHealthStore.isHealthDataAvailable() {
            return true
        }
        let healthStore = HKHealthStore()

        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!

        // check step count authorization status
        healthStore.getRequestStatusForAuthorization(toShare: [stepCountType], read: [stepCountType]) { (status, errorOrNil) in
            if status == HKAuthorizationRequestStatus.unnecessary {
                self.healthKitAuthorized = true
            }
        }

        // Configure Healthkit to wake up the app when step count data samples are available.
        let frequency = HKUpdateFrequency.hourly //available options: hourly, daily, weekly
        healthStore.enableBackgroundDelivery(for: stepCountType, frequency: frequency) { (success, errorOrNil) in
            if let error = errorOrNil {
                self.logger.error("Error enabling Healthkit background deliver for step count updates: \(error.localizedDescription)")
            }
        }

        // Create an long-running query to monitor HealthKit store for step count updates
        let query = HKObserverQuery(sampleType: stepCountType, predicate: nil) { (query, completionHandler, errorOrNil) in
            if let error = errorOrNil {
                self.logger.error("Unable to instantiate step count observer query: \(error.localizedDescription)")
                return
            }
        
            let enrollment = Enrollment.getCurrentEnrollment()
            Analytics.logEvent(FirebaseAnalyticsEvent.didHealthKitStepCountObserverFire.rawValue, parameters: enrollment.toDict())

            self.fetchSensorSamples()
            self.uploadSensorData()

            completionHandler() // Required if background delivery is enabled
        }

        healthStore.execute(query)

        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let enrollment = Enrollment.getCurrentEnrollment()
        Analytics.logEvent(FirebaseAnalyticsEvent.didAppWakeUpForBackgroundFetch.rawValue, parameters: enrollment.toDict())
        
        self.fetchSensorSamples()
        self.uploadSensorData()
        
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

//            if reader.authorizationStatus == SRAuthorizationStatus.authorized {
//                reader.startRecording()
            reader.fetchDevices()
//            }
        }
    }

    // Displays a prompt to request user to authorize sensors
    // If authorization has already been granted, no prompt is displayed
    func requestSensorReaderAuthorization(valid: [Sensor], invalid: [Sensor]) {
        let permittedSensors = Set(valid.map { Sensor.getSRSensor(sensor: $0)}.compactMap { $0 })
        let invalidSensors = Set(invalid.map { Sensor.getSRSensor(sensor: $0)}.compactMap { $0 })
        let allSensors = permittedSensors.union(invalidSensors)

        SRSensorReader.requestAuthorization(sensors: permittedSensors) { (error: Error?) -> Void in
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
                    reader.delegate = SensorReaderDelegate.shared
                    if (invalidSensors.contains(sensor)) {
//                        reader.stopRecording()
                    } else {
                        reader.startRecording()
                        Utils.saveInitialLastFetch(sensor: Sensor.getSensor(sensor: sensor))
                    }
                } else {
                    self.sensorsAuthorized = false
                }
            }
            
            //set sensor authorized as well the current date as the enrolled data for sensors.
            UserDefaults.standard.set(self.sensorsAuthorized, forKey: UserSettingsKeys.sensorsAuthorized)
            //We do this after initializing sensorkit recording so that we know that at least 24 hours have passed since enrollment
            //before we submit first fetch request.
            Thread.sleep(forTimeInterval: 0.25)
            UserDefaults.standard.set(Date(), forKey: UserSettingsKeys.enrolledDate)
        }
    }

    func requestHealthKitAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let healthStore = HKHealthStore()

            let types = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!])

            // request authorization
            healthStore.requestAuthorization(toShare: types, read: types) { (success, error) in
                if (success) {
                    DispatchQueue.main.async {
                        self.healthKitAuthorized = true
                    }
                }
            }
        }
    }
}
