//
//  DeerNoteUITests.swift
//  DeerNoteUITests
//
//  Created by JunHeeJo on 1/29/22.
//

import XCTest

class DeerNoteUITests: XCTestCase {
    var app: XCUIApplication!
    var beforeCount: Int!
    var afterCount: Int!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super .tearDownWithError()
        app = nil
        beforeCount = 0
        afterCount = 0
    }
    
    func test_noteListViewController_whenTapNoteBarButton_shouldPresentNoteEditorViewController() {
        givenEnterNoteEditorViewController()
        
        let navigationBar = app.navigationBars["New"].firstMatch
        
        XCTAssertTrue(navigationBar.exists)
    }
    
    private func givenEnterNoteEditorViewController() {
        app.navigationBars["All"].buttons["addNote"].tap()
    }
    
    func test_noteEditorViewControoler_whenEnter_shouldKeyboardShow() {
        givenEnterNoteEditorViewController()
        
        XCTAssertTrue(app.keyboards.count == 1)
    }
    
    func test_noteEditorViewController_whenTapKeyboardHideButtonKeyboardShowing_shouldHideKeyboard() {
        givenEnterNoteEditorViewController()
        
        app.navigationBars["New"].buttons["keyboardHide"].tap()
        
        XCTAssertTrue(app.keyboards.count == 0)
    }
    
    func test_noteEditorViewController_whenNewNote_shouldTagCellCountIsOne() {
        givenEnterNoteEditorViewController()
        
        let tagTextField = app.textFields["tapTextField"]
        let tagCollectionView = app.collectionViews["tagCollectionView"]
        beforeCount = tagCollectionView.cells.count
        tagTextField.tap()
        
        XCTAssertEqual(beforeCount, 1)
    }
    
    func test_noteEditorViewController_whenAddTag_shouldTagCellCountIncrease() {
        givenEnterNoteEditorViewController()
        
        let tagTextField = app.textFields["tapTextField"]
        let tagCollectionView = app.collectionViews["tagCollectionView"]
        beforeCount = tagCollectionView.cells.count
        tagTextField.tap()
     
        tagTextField.typeText("Tag1")
        tagTextField.typeText("\n")
        tagTextField.typeText("Tag2")
        tagTextField.typeText("\n")
        
        afterCount = tagCollectionView.cells.count
        
        XCTAssertEqual(beforeCount + 2, afterCount)
    }
    
    func test_noteEditorViewController_whenAddExistedTag_shouldTagCellCountIncrease() {
        givenEnterNoteEditorViewController()
        
        let tagTextField = app.textFields["tapTextField"]
        let tagCollectionView = app.collectionViews["tagCollectionView"]
        beforeCount = tagCollectionView.cells.count
        tagTextField.tap()
     
        tagTextField.typeText("Tag1")
        tagTextField.typeText("\n")
        tagTextField.typeText("Tag1")
        tagTextField.typeText("\n")
        
        afterCount = tagCollectionView.cells.count
        
        XCTAssertEqual(beforeCount + 1, afterCount)
    }
    
    func test_noteEditorViewController_whenRemoveTag_shouldTagCellCountDecrease() {
        givenEnterNoteEditorViewController()
        
        let tagTextField = app.textFields["tapTextField"]
        let tagCollectionView = app.collectionViews["tagCollectionView"]
        let removeButton = app.buttons["tagDeleteButton"]
        beforeCount = tagCollectionView.cells.count
        tagTextField.tap()
     
        tagTextField.typeText("Tag1")
        tagTextField.typeText("\n")
        removeButton.tap()
        
        
        afterCount = tagCollectionView.cells.count
        
        XCTAssertEqual(beforeCount, afterCount)
    }
}
