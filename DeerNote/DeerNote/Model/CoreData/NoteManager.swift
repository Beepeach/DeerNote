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
    
    var allNotes: [NoteEntity] = []
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
    
    private func update(note: NoteEntity, contents: String) {
        note.contents = contents
        note.modifiedDate = Date()
        
        if coredataManager.mainContext.hasChanges {
            coredataManager.saveMainContext()
            print("Edit Note")
        }
    }
    
    private func addNote(contents: String) {
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
    
    func moveTrash(note: NoteEntity) {
        note.isDeletedNote = true
        
        if coredataManager.mainContext.hasChanges {
            coredataManager.saveMainContext()
        }
    }
}


