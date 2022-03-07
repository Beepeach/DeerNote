//
//  TagManagerTests.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 3/7/22.
//

import XCTest
import CoreData
@testable import DeerNote

class TagManagerTests: XCTestCase {
    var sut: TagManager!
    var noteManager: NoteManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TagManager(coredataManager: MockCoreDataManager())
        noteManager = NoteManager(coredataManager: MockCoreDataManager())
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        noteManager = nil
    }
    
    func test_whenThest_shouldUserMockCoreDataManager() {
        XCTAssertTrue(sut.coredataManager is MockCoreDataManager)
    }
    
    func test_whenInit_shouldAllTagsAreEmpty() {
        let allTags = sut.fetchTags(with: TagEntity.fetchRequest())
        XCTAssertTrue(allTags.isEmpty)
    }
    
    func test_setupAllTagFetchRequest_shouldBringCorrectAllTags() {
        let tag = TagEntity(context: sut.coredataManager.mainContext)
        tag.name = "Tag"
        let anotherTag = TagEntity(context: sut.coredataManager.mainContext)
        anotherTag.name = "AnotherTag"
                            
        
        let allTags = sut.fetchTags(with: sut.setupAllTagsFetchRequest(sort: []))
        
        XCTAssertEqual(2, allTags.count)
    }
    
    func test_setupTargetTagFetchRequest_shouldBringTargetTags() {
        let tag = TagEntity(context: sut.coredataManager.mainContext)
        tag.name = "Tag"
        
        let targetTag = sut.fetchTags(with: sut.setupTargetTagFetchRequest(name: tag.name!))
        
        XCTAssertEqual(tag.name!, targetTag.first!.name)
    }
    
    func test_createNewTags_whenExistTag_shouldReturnNil() {
        let tag = TagEntity(context: sut.coredataManager.mainContext)
        tag.name = "Tag"
        
        XCTAssertNil(sut.createNewTags(name: "Tag"))
    }
    
    func test_createNteTags_whenNoExistTag_shouldSave() {
        let newTag = sut.createNewTags(name: "Tag")!
        
        let targetTag = sut.fetchTags(with: TagEntity.fetchRequest()).first!
        
        XCTAssertEqual(targetTag.name, newTag.name)
    }
    
    func test_whenDeleteTag_shouldDeletePersistentStore() {
        let tag = TagEntity(context: sut.coredataManager.mainContext)
        tag.name = "Tag"
        
        sut.delete(tag: tag)
        
        XCTAssertNil(sut.fetchTags(with: TagEntity.fetchRequest()).first)
    }
    
    func test_whenDeleteTag_shouldDeleteRelation() {
        let tag = TagEntity(context: sut.coredataManager.mainContext)
        tag.name = "Tag"
        let note = NoteEntity(context: noteManager.coredataManager.mainContext)
        note.contents = "Note"
        tag.addToNotes(note)
        note.addToTags(tag)
        XCTAssertTrue(tag.notes!.count != 0)
        XCTAssertTrue(note.tags!.count != 0)
        
        sut.delete(tag: tag, in: note)
        
        XCTAssertTrue(tag.notes!.count == 0)
        XCTAssertTrue(note.tags!.count == 0)
    }
}
