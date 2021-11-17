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

/*
 Sets up the CoreData stack
 ref: https://developer.apple.com/documentation/coredata/setting_up_a_core_data_stack
 */
class PersistenceController {
    
    // logging
    let logger = Logger(subsystem: "com.openlattice.chronicle", category: "Persistence")
    
    // shared instance to provide access to core data
    static let shared = PersistenceController()
    
    
    lazy var persistentContainer: NSPersistentContainer? = {
        let container = NSPersistentContainer(name: "SensorDataModel")
        
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
    func newBackgroundContext() -> NSManagedObjectContext? {
        guard persistentContainer != nil else {
            logger.error("persistent container not initialized")
            return nil
        }
        
        let taskContext = persistentContainer!.newBackgroundContext()
        taskContext.automaticallyMergesChangesFromParent = true
        return taskContext
    }
}
