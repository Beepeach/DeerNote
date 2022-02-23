//
//  CoreDataManager.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/18/22.
//

import Foundation
import CoreData

class CoreDataManager {
    // MARK: Properties
    static let shared: CoreDataManager = CoreDataManager()
    var container: NSPersistentContainer?
    var mainContext: NSManagedObjectContext {
        guard let context = container?.viewContext else {
            // TODO: - Error처리 코드를 넣어줍시다.
            fatalError("ContextError")
        }
        
        return context
    }
    
    // MARK: Initializer
    // UITest를 위해서 private 제거
    init() { }
    
    // MARK: Methods
    func setup(modelName: String) {
        container = NSPersistentContainer(name: "DeerNote")
        container?.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error {
                // TODO: - Error처리 코드를 넣어줍시다.
                fatalError(error.localizedDescription)
            }
        })
    }
    
    func saveMainContext() {
        mainContext.perform { [weak self] in
            if self?.mainContext.hasChanges ?? false {
                self?.saveContext()
            }
        }
    }
    
    private func saveContext() {
        do {
            try mainContext.save()
            print("Save Main Context")
        } catch {
            // TODO: - SaveError처리 코드를 넣어줍시다.
            print(error.localizedDescription)
        }
    }
}


