//
//  MockCoreDataManager.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 2/18/22.
//

import Foundation
import CoreData
@testable import DeerNote

// 메모리에만 저장하는 MockCoreData입니다.
class MockCoreDataManager: CoreDataManager {
//    override func saveMainContext() {
//    }
    
    override var mainContext: NSManagedObjectContext {
        return testContainer.viewContext
    }
    
    lazy var testContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: "DeerNote")
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
        }
        
        return container
    }()
}
