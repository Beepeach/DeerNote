//
//  NoteManager.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/20/22.
//

import Foundation
import CoreData

class NoteManager {
    static let shared: NoteManager = NoteManager()
    
    private var allNotes: [NoteEntity] = []
    private let coredataManager = CoreDataManager.shared
    
    func fetchAllNote(with sortDescriptors: [NSSortDescriptor]) -> [NoteEntity]? {
        let allNotefetchRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        allNotefetchRequest.sortDescriptors = sortDescriptors
        
        do {
            return try coredataManager.mainContext.fetch(allNotefetchRequest)
        } catch {
            // TODO: - fetch실패시 에러처리를 해야합니다.
            print(#function, print(error.localizedDescription))
            return nil
        }
    }
    
    func fetchRequest() -> NSFetchRequest<NoteEntity> {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        let modifiedAscendSortDescriptor = NSSortDescriptor(key: "modifiedDate", ascending: false)
        request.predicate = NSPredicate(format: "isDeletedNote == false")
        request.sortDescriptors = [modifiedAscendSortDescriptor]
        request.fetchBatchSize = 20
        
        return request
    }
    
    func addNote(contents: String) {
        // TODO: - Tag를 추가하는 코드가 들어가야합니다.
        let newNote = NoteEntity(context: CoreDataManager.shared.mainContext)
        let currentData = Date()
        let randomColor = GradationColor.shared.getRandomColor()
        
        newNote.contents = contents
        newNote.createdDate = currentData
        newNote.modifiedDate = currentData
        newNote.isDeletedNote = false
        newNote.fromColor = randomColor.from
        newNote.toColor = randomColor.to
        
        if coredataManager.mainContext.hasChanges {
            coredataManager.saveMainContext()
        }
        print("Add Note")
    }
    
    func update(_ note: NoteEntity, contents: String) {
        guard note.contents != contents else {
            return
        }
        note.contents = contents
        note.modifiedDate = Date()
        
        if coredataManager.mainContext.hasChanges {
            coredataManager.saveMainContext()
            print("Edit Note")
        }
    }
    
    func moveTrash(note: NoteEntity) {
        note.isDeletedNote = true
        
        if coredataManager.mainContext.hasChanges {
            coredataManager.saveMainContext()
        }
    }
}


