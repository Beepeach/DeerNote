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
    var coredataManager: CoreDataManager
    private var allNotes: [NoteEntity] = []
    
    init(coredataManager: CoreDataManager = CoreDataManager.shared ) {
        self.coredataManager = coredataManager
    }
    
    // MARK: Methods
    func fetchNotes(with request: NSFetchRequest<NoteEntity>) -> [NoteEntity]? {
        do {
            allNotes = try coredataManager.mainContext.fetch(request)
            return allNotes
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
    
    @discardableResult
    func addNote(contents: String, tags: [Tag]) -> NoteEntity {
        let newNote = createNewNote(contents)
        connectTagAndNote(tags: tags, note: newNote)
        
        allNotes.append(newNote)
        
        coredataManager.saveMainContext()
        print("Add Note")
        return newNote
    }
    
    private func connectTagAndNote(tags: [Tag], note: NoteEntity) {
        tags.forEach {
            let fetchRequest = TagManager.shared.setupTargetTagFetchRequest(name: $0.name)
            guard let tagEntity = TagManager.shared.fetchTags(with: fetchRequest).first else {
                return
            }
            
            if note.tags?.contains(tagEntity) ?? true  {
                print("Already connet note to tag")
               return
            }
            
            note.addToTags(tagEntity)
            tagEntity.addToNotes(note)
            print("Add \(tagEntity.name ?? "") to Note")
            print("Add \(note.contents ?? "") \(note.id) to Tag")
        }
    }
    
    @discardableResult
    private func createNewNote(_ contents: String) -> NoteEntity {
        let newNote = NoteEntity(context: coredataManager.mainContext)
        let currentData = Date()
        let randomColor = GradationColor().getRandomColor()
        
        newNote.contents = contents
        newNote.createdDate = currentData
        newNote.modifiedDate = currentData
        newNote.isDeletedNote = false
        newNote.fromColor = randomColor.from
        newNote.toColor = randomColor.to
        
        return newNote
    }
    
    func update(_ note: NoteEntity, contents: String, tags: [Tag], isChanged: Bool) {
        if note.contents != contents {
            note.contents = contents
            note.modifiedDate = Date()
        }
        
        if isChanged == true {
            connectTagAndNote(tags: tags, note: note)
        }

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
    
    func update(_ note: NoteEntity, pinnedDate: Date?) {
        note.pinnedDate = pinnedDate
        
        coredataManager.saveMainContext()
    }
    
    @discardableResult
    func delete(note: NoteEntity) -> Bool {
        if let targetNoteIndex = allNotes.firstIndex(of: note) {
            allNotes.remove(at: targetNoteIndex)
            coredataManager.mainContext.delete(note)
            coredataManager.saveMainContext()
            print("Delete note")
            return true
        }
        
        return false
    }
    
    //TODO: 이게 굳이 필요할까???
    func deleteWithNoSave(note: NoteEntity) {
        coredataManager.mainContext.delete(note)
        print("Delete note with no save")
    }
    
    func moveTrash(note: NoteEntity) {
        note.isDeletedNote = true
        note.deletedDate = Date()
        note.customSortIndex = 0
        note.pinnedDate = nil
        
        coredataManager.saveMainContext()
        print("Move Trash")
    }
    
    func restore(note: NoteEntity) {
        note.isDeletedNote = false
        note.deletedDate = nil
        coredataManager.saveMainContext()
        print("Restore note")
    }
}


