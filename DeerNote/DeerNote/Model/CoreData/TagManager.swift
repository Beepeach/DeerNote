//
//  TagManager.swift
//  DeerNote
//
//  Created by JunHeeJo on 2/25/22.
//

import Foundation
import CoreData

class TagManager {
    // MARK: Properties
    static let shared: TagManager = TagManager()
    private var allTags: [TagEntity] = []
    var coredataManager: CoreDataManager
    
    init(coredataManager: CoreDataManager = CoreDataManager.shared) {
        self.coredataManager = coredataManager
    }
    
    // MARK: Methods
    func fetchTags(with request: NSFetchRequest<TagEntity>) -> [TagEntity] {
        var list: [TagEntity] = []
        
        coredataManager.mainContext.performAndWait {
            do {
                list = try coredataManager.mainContext.fetch(request)
            } catch {
                // TODO: - Fetch 실패시 에러처리를 해야합니다.
                print(#function, print(error.localizedDescription))
            }
        }
        
        return list
    }
    
    func setupAllTagsFetchRequest(sort sortDescriptors: [NSSortDescriptor]) -> NSFetchRequest<TagEntity> {
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        fetchRequest.sortDescriptors = sortDescriptors
        
        return fetchRequest
    }
    
    func setupTargetTagFetchRequest(name: String) -> NSFetchRequest<TagEntity> {
        let fetchRequest: NSFetchRequest<TagEntity> = TagEntity.fetchRequest()
        let predicate: NSPredicate = NSPredicate(format: "%K == %@", #keyPath(TagEntity.name), name)
        fetchRequest.predicate = predicate
        
        return fetchRequest
    }
    
    @discardableResult
    func createNewTags(name: String) -> TagEntity? {
        let nameASCE: NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let request: NSFetchRequest<TagEntity> = setupAllTagsFetchRequest(sort: [nameASCE])
        let allTags = fetchTags(with: request)
        
        if allTags.contains(where: { $0.name == name }) {
            print("Exist Tag")
            return nil
        }
       
        let newTag: TagEntity = TagEntity(context: coredataManager.mainContext)
        newTag.name = name
        print("Create Tag")
        
        return newTag
    }
    
    func delete(tag: TagEntity) {
        coredataManager.mainContext.delete(tag)
        coredataManager.saveMainContext()
        
        guard let taggedNotes = tag.notes as? Set<NoteEntity> else {
            return
        }
        taggedNotes.forEach { delete(tag: tag, in: $0) }
    }
    
    func delete(tag: TagEntity, in note: NoteEntity) {
        note.removeFromTags(tag)
        tag.removeFromNotes(note)
        print("remove relation \(note.contents ?? "") \(tag.name ?? "")")
    }
}
