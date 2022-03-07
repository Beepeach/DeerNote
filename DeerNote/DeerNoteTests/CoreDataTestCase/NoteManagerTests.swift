//
//  NoteManagerTests.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 2/23/22.
//

import XCTest
@testable import DeerNote
import CoreData

class NoteManagerTests: XCTestCase {
    var sut: NoteManager!
    var tagManager: TagManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NoteManager(coredataManager: MockCoreDataManager())
        tagManager = TagManager(coredataManager: MockCoreDataManager())
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
        tagManager = nil
    }
    
    private func givenFetchAllNote() -> [NoteEntity] {
        return sut.fetchNotes(with: givenFetchRequest())!
    }
    
    private func givenFetchRequest() -> NSFetchRequest<NoteEntity> {
        return NoteEntity.fetchRequest()
    }
    
    func test_whenTest_shouldUseMockCoreDataManager() {
        XCTAssertTrue(sut.coredataManager is MockCoreDataManager)
    }

    func test_whenInit_shouldAllNotesAreEmpty() {
        let allNotes = givenFetchAllNote()
        XCTAssertTrue(allNotes.isEmpty)
    }
    
    func test_setupAllNoteFetchRequest_whenTrashParameteIsTrue_isDeletedNoteTrue() {
        let request = sut.setupAllNoteFetchRequest(sort: [], trash: true)
        XCTAssertTrue(request.predicate!.description == "isDeletedNote == 1")
    }
    
    func test_setupAllNoteFetchRequest_whenTrashParameteIsFalse_isDeletedNoteFalse() {
        let request = sut.setupAllNoteFetchRequest(sort: [], trash: false)
        XCTAssertTrue(request.predicate!.description == "isDeletedNote == 0")
    }
    
    func test_whenFetchNote_shouldBringCorrectNotes() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "2"
        
        XCTAssertTrue(targetNote.contents == "2")
    }
        
    func test_whenAddNote_shouldInsertNote() {
        let beforeAllNoteCount = givenFetchAllNote().count
        
        sut.addNote(contents: "1", tags: [])
        let afterAllNoteCount = givenFetchAllNote().count
        
        XCTAssertEqual(beforeAllNoteCount + 1, afterAllNoteCount)
    }
    
    func test_whenUpdateNoteContent_shouldChangeContent() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "Note"
        XCTAssertEqual(targetNote.contents, "Note")
        
        sut.update(targetNote, contents: "Updated", tags: [], isChanged: false)
        
        XCTAssertEqual(targetNote.contents, "Updated")
    }
    
    func test_whenUpdateNoteContent_shouldChangeModifiedDate() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "Note"
        targetNote.modifiedDate = Date()
        let beforeDate = targetNote.modifiedDate!
        
        sut.update(targetNote, contents: "Updated", tags: [], isChanged: false)
        let afterDate = targetNote.modifiedDate!
        
        XCTAssertGreaterThan(afterDate, beforeDate)
    }
    
    func test_whenUpdateNoteWithoutContentChanged_shouldNotChangeModifiedDate() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "Note"
        targetNote.modifiedDate = Date()
        let beforeDate = targetNote.modifiedDate!
        
        sut.update(targetNote, contents: "Note", tags: [], isChanged: false)
        let afterDate = targetNote.modifiedDate!
        
        XCTAssertEqual(afterDate, beforeDate)
    }
    
    func test_whenAddNote_shouldSortIndexIsZero() {
        let targetNote = sut.addNote(contents: "Sorted", tags: [])
        
        XCTAssertEqual(targetNote.customSortIndex, 0)
    }
    
    func test_whenUpdateSortIndex_shouldChangedSortIndex() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "Note"
        targetNote.customSortIndex = 0
        
        sut.update(targetNote, sortIndex: 2)
        let afterTargetNoteSortIndex = targetNote.customSortIndex
        
        XCTAssertEqual(afterTargetNoteSortIndex, 2)
    }
    
    func test_whenAddNote_shouldPinnedDateIsNil() {
        let targetNote = sut.addNote(contents: "Pinned", tags: [])
        
        XCTAssertNil(targetNote.pinnedDate)
    }
    
    func test_whenUpdatePinnedDate_shouldSavaPinnedDate() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "Pinned"
        let currentDate = Date()
        sut.update(targetNote, pinnedDate: currentDate)
        
        XCTAssertEqual(targetNote.pinnedDate!, currentDate)
    }
    
    func test_whenDeleteNote_shouldRemove() {
        let targetNote = sut.addNote(contents: "Deleted", tags: [])
        
        XCTAssertTrue(sut.delete(note: targetNote))
    }
    
    func test_whenAddNote_isDeleteNote_shouldFalse() {
        sut.addNote(contents: "Trash", tags: [])
        let targetNote = givenFetchAllNote().first!
        
        XCTAssertFalse(targetNote.isDeletedNote)
    }
    
    func test_whenMoveTrash_isDeletedNote_shouldTrue() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "Trash"
        
        sut.moveTrash(note: targetNote)
        
        XCTAssertTrue(targetNote.isDeletedNote)
    }
    
    func test_whenResotre_isDeletedNote_shouldFalse() {
        let targetNote = NoteEntity(context: sut.coredataManager.mainContext)
        targetNote.contents = "Trash"
        targetNote.isDeletedNote = true
        
        sut.restore(note: targetNote)
        XCTAssertFalse(targetNote.isDeletedNote)
    }
    
    
    // TODO: - TagEntity와 연결되는지 확인하는 테스트가 추가되어야합니다.
    // 현재 tag를 저장하는 코드가 분리되어있어 테스트 하기 힘듭니다.
    // 구조를 변경해야합니다.
    
    //    func test_whenAddNoteWithTag_shouldConnectTags() {
    //        sut.addNote(contents: "TagNote", tags: [Tag(name: "Tag1"), Tag(name: "Tag2")])
    //    }
}
