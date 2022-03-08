//
//  DeerNoteUITests.swift
//  DeerNoteUITests
//
//  Created by JunHeeJo on 1/29/22.
//

import XCTest

class DeerNoteUITests: XCTestCase {
    var app: XCUIApplication!
    var noteBeforeCount: Int!
    var noteAfterCount: Int!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super .tearDownWithError()
        app = nil
        noteBeforeCount = 0
        noteAfterCount = 0
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
}
