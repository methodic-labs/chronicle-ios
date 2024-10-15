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
        
        // Configure background health processing task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.getmethodic.chronicle.fetchSensorSamples", using: nil ) { task in
            self.handleFetchSensorSamples(task: task as! BGProcessingTask)
        }
        
        logger.info("Registered handlers for fetchSensorSamples task.")
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.getmethodic.chronicle.fetchSensorSamplesHeavy", using: nil ) { task in
            self.handleFetchSensorSamples(task: task as! BGProcessingTask)
        }
        
        logger.info("Registered handlers for fetchSensorSamplesHeavy task.")
        
        scheduleFetchSensorSamplesTask()
        
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
                self.registerBackgroundHealthKitQuery(healthStore: healthStore, stepCountType: stepCountType)
            }
        }
        
        self.fetchSensorSamples()
        
        return true
    }
    
    func registerBackgroundHealthKitQuery(healthStore: HKHealthStore, stepCountType: HKQuantityType) {
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
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let enrollment = Enrollment.getCurrentEnrollment()
        Analytics.logEvent(FirebaseAnalyticsEvent.didAppWakeUpForBackgroundFetch.rawValue, parameters: enrollment.toDict())
        
        self.scheduleFetchSensorSamplesTask()
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

    func scheduleFetchSensorSamplesTask() {
        
        let fetchSensorSamplesTask = if #available(iOS 17.0, *) {
            {
                let tr = BGHealthResearchTaskRequest(identifier: "com.getmethodic.chronicle.fetchSensorSamples")
                tr.requiresExternalPower = false
                tr.requiresNetworkConnectivity = false
                return tr
            }()
        } else {
            BGAppRefreshTaskRequest(identifier: "com.getmethodic.chronicle.fetchSensorSamples" )
        }
        
        fetchSensorSamplesTask.earliestBeginDate = Date(timeIntervalSinceNow: 15*60) // Schedule it to run sometime after the next 15 minutes.
        
        do {
            try BGTaskScheduler.shared.submit(fetchSensorSamplesTask)
        } catch {
            logger.error("Failed to submit health research task: \(error)")
            let eventLogParams = Enrollment.getCurrentEnrollment().toDict()
            Analytics.logEvent(FirebaseAnalyticsEvent.backgroundHealthTaskRegistrationFailed.rawValue, parameters: eventLogParams)
        }
    }
    
    func scheduleFetchSensorSamplesHeavyTask() {
        let fetchSensorSamplesTask = BGProcessingTaskRequest(identifier: "com.getmethodic.chronicle.fetchSensorSamplesHeavy" )
        fetchSensorSamplesTask.requiresExternalPower = false
        fetchSensorSamplesTask.requiresNetworkConnectivity = false
        fetchSensorSamplesTask.earliestBeginDate = Date(timeIntervalSinceNow: 12*60*60) // Schedule it to run sometime after the next 12 hours.
        
        do {
            try BGTaskScheduler.shared.submit(fetchSensorSamplesTask)
        } catch {
            logger.error("Failed to submit processing task: \(error)")
            let eventLogParams = Enrollment.getCurrentEnrollment().toDict()
            Analytics.logEvent(FirebaseAnalyticsEvent.backgroundHealthTaskRegistrationFailed.rawValue, parameters: eventLogParams)
        }
    }
    
    func handleFetchSensorSamples( task: BGProcessingTask ) {
        handleFetchSensorSamples(task: task as BGTask)
    }
    
    func handleFetchSesnsorSamples( task: BGAppRefreshTask ) {
        handleFetchSensorSamples(task: task as BGTask)
    }
    
    func handleFetchSensorSamples(task: BGTask) {
        logger.info("Executing fetch sensor samples task.")
        let sensors = SensorReaderDelegate.availableSensors
        var successfulFetch = false
        var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
        sensors.forEach { sensor in
            let reader = SRSensorReader(sensor: sensor)
            reader.delegate = SensorReaderDelegate.shared
            if reader.authorizationStatus == SRAuthorizationStatus.authorized {
                reader.startRecording()
            }
            let request = SRFetchRequest()
            request.from = SRAbsoluteTime.init(0.0)
            request.to = SRAbsoluteTime.current()
            eventLogParams.merge(["startDate": Date(timeIntervalSinceReferenceDate: request.from.toCFAbsoluteTime()).toISOFormat(), "endDate": Date(timeIntervalSinceReferenceDate: request.to.toCFAbsoluteTime()).toISOFormat()]) { (current, _) in current }
            reader.fetch(request)
            reader.fetchDevices()
        }
        
        successfulFetch = true
        
        task.expirationHandler = {
            self.scheduleFetchSensorSamplesTask()
            let logger = Logger(subsystem: "com.openlattice.chronicle", category: "SensorReader")
            logger.info("SensorKit fetch task expiring.")
            if !successfulFetch {
                logger.error("Unable to submit fetch requests.")
                let eventLogParams = Enrollment.getCurrentEnrollment().toDict()
                Analytics.logEvent(FirebaseAnalyticsEvent.backgroundHealthTaskFetchFailed.rawValue, parameters: eventLogParams)
            }
            // Task will always expire
            SensorReaderDelegate.fetching.signal()
        }
        
        // We wait twice on single semaphore as we wait as long as iOS will let us to fetch data.
        SensorReaderDelegate.fetching.wait()
        
        task.setTaskCompleted(success: true)
        
        scheduleFetchSensorSamplesTask()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleFetchSensorSamplesTask()
    }
    
    func fetchSensorSamples() {
        let sensors = SensorReaderDelegate.availableSensors
        var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
        sensors.forEach { sensor in
            let reader = SRSensorReader(sensor: sensor)
            reader.delegate = SensorReaderDelegate.shared
            
            if reader.authorizationStatus == SRAuthorizationStatus.authorized {
                reader.startRecording()
            }
            let request = SRFetchRequest()
            request.from = SRAbsoluteTime.init(0.0)
            request.to = SRAbsoluteTime.current()
            
            eventLogParams.merge(["startDate": Date(timeIntervalSinceReferenceDate: request.from.toCFAbsoluteTime()).toISOFormat(), "endDate": Date(timeIntervalSinceReferenceDate: request.to.toCFAbsoluteTime()).toISOFormat()]) { (current, _) in current }
            reader.fetch(request)
            reader.fetchDevices()
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
                        reader.stopRecording()
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
                        self.registerBackgroundHealthKitQuery(healthStore: healthStore, stepCountType: types.first!)
                    }
                }
            }
        }
    }
    
//    func submitFetchRequestForSensor(reader: SRSensorReader) {
//        let enrolledDate = UserDefaults.standard.object(forKey: UserSettingsKeys.enrolledDate) as? Date ?? Date()
//        
//        let hoursElapsedSinceEnrollment = Calendar.current.dateComponents([.hour], from: enrolledDate, to: Date()).hour ?? 0
//        let secondsSinceEnrollment = Calendar.current.dateComponents([.second], from: enrolledDate, to: Date()).second ?? 0
//        let enrollmentAbsoluteTime = SRAbsoluteTime.init(SRAbsoluteTime.current().rawValue - Double(secondsSinceEnrollment))
//        
//        //Don't submit any fetch requests until at least 24 hours have passed since enrollment
//        //as SensorKit holds values for 24 hours to allow user to delete them.
//        if( hoursElapsedSinceEnrollment < 24) {
//            return
//        }
//        
//        var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
//        eventLogParams.merge(["devices": devices.description, "hoursElapsedSinceEnrollment" : String(hoursElapsedSinceEnrollment)]) { (current, _) in current }
//        
//        Analytics.logEvent(FirebaseAnalyticsEvent.didFetchSensorDevices.rawValue, parameters: eventLogParams)
//        
//        
//        
//            let request = SRFetchRequest()
//            
//            request.device = device
//            
//            let sevenDaysAgo = request.to.rawValue - 7*twentyFourHoursInSeconds.rawValue
//            
//            let lastFetch = Utils.getLastFetch(
//                device: SensorReaderDevice(device: device),
//                sensor: Sensor.getSensor(sensor: reader.sensor)
//            ) ?? SRAbsoluteTime.init(max(sevenDaysAgo, enrollmentAbsoluteTime.rawValue))
//            
//            //Let's ask for all the data.
//            request.from = SRAbsoluteTime.init(0.0)// lastFetch
//            // Only request data that is older than 24 hours.
//            request.to = SRAbsoluteTime.current()//SRAbsoluteTime.init(SRAbsoluteTime.current().rawValue - twentyFourHoursInSeconds.rawValue)
//            // Let's get ISO dates for readable logs.
//            
//            let startDate = Date(timeIntervalSinceReferenceDate: request.from.toCFAbsoluteTime())
//            let endDate  = Date(timeIntervalSinceReferenceDate: request.to.toCFAbsoluteTime())
//            
//            logger.info("fetching data for \(reader.sensor.rawValue) -  start: \(startDate.description), end: \(endDate.description)")
//            reader.fetch(request)
//            
//            var eventLogParams = Enrollment.getCurrentEnrollment().toDict()
//            eventLogParams.merge(["device": device.description, "startDate": startDate.toISOFormat(), "endDate": endDate.toISOFormat(), "hoursElapsedSinceEnrollment" : String(hoursElapsedSinceEnrollment)]) { (current, _) in current }
//            
//            Analytics.logEvent(FirebaseAnalyticsEvent.didFetchSensorDevices.rawValue, parameters: eventLogParams)
//            
//            let timestampIso = Date(timeIntervalSinceReferenceDate: SRAbsoluteTime.current().toCFAbsoluteTime()).toISOFormat()
//            UserDefaults.standard.set(timestampIso, forKey:UserSettingsKeys.lastFetchSubmitted)
//        }
//    }
}
