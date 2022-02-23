//
//  NoteManagerTests.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 2/23/22.
//

import XCTest
@testable import DeerNote

class NoteManagerTests: XCTestCase {
    var sut: NoteManager!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockNoteManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        print(sut.coredataManager)
    }
}
