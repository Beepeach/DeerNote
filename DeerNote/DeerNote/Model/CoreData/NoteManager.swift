//
//  NoteManager.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/20/22.
//

import Foundation
import CoreData

class NoteManager {
    // MARK: Properties
    static let shared: NoteManager = NoteManager()
    private var allNotes: [NoteEntity] = []
    var coredataManager = CoreDataManager.shared
    
    // MARK: Methods
    func fetchNotes(with request: NSFetchRequest<NoteEntity>) -> [NoteEntity]? {
        do {
            return try coredataManager.mainContext.fetch(request)
        } catch {
            // TODO: - fetch실패시 에러처리를 해야합니다.
            print(#function, print(error.localizedDescription))
            return nil
        }
    }
    
    func setupAllNoteFetchRequest(sort sortDescriptors: [NSSortDescriptor], trash: Bool) -> NSFetchRequest<NoteEntity> {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        if trash == true {
            request.predicate = NSPredicate(format: "isDeletedNote == true")
        } else {
            request.predicate = NSPredicate(format: "isDeletedNote == false")
        }
        request.sortDescriptors = sortDescriptors
        request.fetchBatchSize = 20
        
        return request
    }
    
    func addNote(contents: String) {
        // TODO: - Tag를 추가하는 코드가 들어가야합니다.
        createNewNote(contents)
        
        coredataManager.saveMainContext()
        print("Add Note")
    }
    
    private func createNewNote(_ contents: String) {
        let newNote = NoteEntity(context: CoreDataManager.shared.mainContext)
        let currentData = Date()
        let randomColor = GradationColor.shared.getRandomColor()
        
        newNote.contents = contents
        newNote.createdDate = currentData
        newNote.modifiedDate = currentData
        newNote.isDeletedNote = false
        newNote.fromColor = randomColor.from
        newNote.toColor = randomColor.to
    }
    
    func update(_ note: NoteEntity, contents: String) {
        guard note.contents != contents else {
            return
        }
        note.contents = contents
        note.modifiedDate = Date()
        
        coredataManager.saveMainContext()
        print("Edit Note")
    }
    
    func update(_ note: NoteEntity, sortIndex: Int) {
        note.customSortIndex = Int64(sortIndex)
        
        coredataManager.saveMainContext()
        print("Update customSortIndex \(sortIndex)")
    }
    
    func updateWithNoSave(_ note: NoteEntity, sortIndex: Int) {
        if note.customSortIndex != Int64(sortIndex) {
            note.customSortIndex = Int64(sortIndex)
            print("Only customSortIndex\(sortIndex) update with no save")
        }
    }
    
    func moveTrash(note: NoteEntity) {
        note.isDeletedNote = true
        note.deletedDate = Date()
        
        coredataManager.saveMainContext()
        print("Move Trash")
    }
}


