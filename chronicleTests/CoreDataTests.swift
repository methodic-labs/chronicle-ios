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
        
        // delete all locally stored data
        let request = SensorData.fetchRequest()
        let objects = try? context?.fetch(request)
        
        guard let objects = objects, let context = context else {
            return
        }
        objects.forEach(context.delete)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testImportDataSample() {
        guard let context = context else {
            return
        }
        
        Sensor.allCases.forEach {
            let sample = TestUtils.mockSensorDataSample(sensor: $0)
            XCTAssertTrue(sample.isValidSample)
            
            let operation = ImportIntoCoreDataOperation(context: context, data: sample)
            operation.main()
            
            Thread.sleep(forTimeInterval: 2.0)
            
            let fetchRequest: NSFetchRequest<SensorData> = SensorData.fetchRequest()
            let objects = try? context.fetch(fetchRequest)
            XCTAssertNotNil(objects)
            XCTAssertTrue(!objects!.isEmpty)
            XCTAssertTrue(objects!.count == 1)
            
            let datasource = Datasource(source: objects!.first!)
            
            let data = String(data: sample.data!, encoding: .utf8)
            let device = String(data: sample.device!, encoding: .utf8)
            
            XCTAssertEqual(device, datasource.device)
            XCTAssertEqual(data, datasource.data)
            XCTAssertEqual(sample.sensor, datasource.sensor)
            XCTAssertEqual(sample.writeTimestamp.toISOFormat(), datasource.dateRecorded)
            XCTAssertEqual(sample.duration, datasource.duration)
            XCTAssertEqual(sample.timezone, datasource.timezone)
            XCTAssertEqual(objects?.first?.id, datasource.id)
            
            objects!.forEach(context.delete)
            Thread.sleep(forTimeInterval: 2.0)
        }
    }
}
