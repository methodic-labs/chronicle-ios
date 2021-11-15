//
//  Persistence.swift
//  Persistence
//
//  Created by Alfonce Nzioka on 11/7/21.
//

import Foundation
import OSLog
import CoreData
import SensorKit

// This class sets up the CoreData stack
class PersistenceController {
    
    // logging
    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "Persistence")
    
    // shared instance to provide access to core data
    static let shared = PersistenceController()
    
    // hold data in memory or store on disk
    private let inMemory: Bool
    
    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
    }
    
    // persistence container to set up the Core Data Stack. This is only available for iOS 10.0+
    // set up model, context and store coordinator at once: https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack
    
    lazy var persistentContainer: NSPersistentContainer? = {
        let container = NSPersistentContainer(name: "SensorDataModel")
        
        guard let description = container.persistentStoreDescriptions.first else {
            self.logger.error("Failed to retrieve a persistent store description")
            return nil
        }
        
        // keep in memory instead of writing to disk.
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // load
        var loadError = false
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                self.logger.error("Unresolved error: \(error), \(error.userInfo)")
                loadError = true
            }
        }
        
        if loadError {
            return nil
        }
        
        return container
    }()
    
    lazy var backgroundContext: NSManagedObjectContext? = {
        let context = newTaskContext()
        return context
    }()
    
    // creates and configures a background context
    func newTaskContext() -> NSManagedObjectContext? {
        guard persistentContainer != nil else {
            logger.error("persistent container not initialized")
            return nil
        }
        
        let taskContext = persistentContainer!.newBackgroundContext()
        taskContext.automaticallyMergesChangesFromParent = true
        return taskContext
    }
}
