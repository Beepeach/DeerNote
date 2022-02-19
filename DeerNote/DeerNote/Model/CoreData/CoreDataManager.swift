//
//  CoreDataManager.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/18/22.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    
    // UITest를 위해서 private 제거
    init() { }
    
    var container: NSPersistentContainer?
    
    var mainContext: NSManagedObjectContext {
        guard let context = container?.viewContext else {
            // TODO: - Error처리 코드를 넣어줍시다.
            fatalError("ContextError")
        }
        
        return context
    }
    
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
        mainContext.perform {
            if self.mainContext.hasChanges {
                do {
                    try self.mainContext.save()
                } catch {
                    // TODO: - SaveError처리 코드를 넣어줍시다.
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func addNote() {
        let newNote = NoteEntity(context: CoreDataManager.shared.mainContext)
        newNote.contents = "test"
        newNote.createDate = Date()
        newNote.updateDate = Date()
        newNote.isDeletedNote = false
        
        saveMainContext()
        print("Add")
    }
}


