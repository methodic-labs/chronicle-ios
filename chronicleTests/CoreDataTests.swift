//
//  CoreDataTests.swift
//  chronicleTests
//
//  Created by Alfonce Nzioka on 2/1/22.
//  Copyright © 2022 OpenLattice, Inc. All rights reserved.
//

import XCTest
import CoreData
@testable import chronicle

class CoreDataTests: XCTestCase {

    var context: NSManagedObjectContext?
    let appDelegate = AppDelegate()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let container = PersistenceController.preview.persistentContainer
        guard let container = container else {
            fatalError("unable to set up core data stack")
        }
        context = container.viewContext
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testStoreDeviceUsageDataSample() {
        guard let context = context else {
            return
        }
        
        let data = TestUtils.mockSensorDataSample(sensor: Sensor.deviceUsage)
        XCTAssertTrue(data.isValidSample)
        
        let operation = ImportIntoCoreDataOperation(context: context, data: data)
        
        operation.completionBlock = {
      
            let fetchRequest: NSFetchRequest<SensorData> = SensorData.fetchRequest()
            let objects = try? context.fetch(fetchRequest)
            XCTAssertNotNil(objects)
            XCTAssertTrue(objects!.count == 1)
            
            
            
        }
    }
}
