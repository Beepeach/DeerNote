//
//  CoreDataManagerTests.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 2/18/22.
//

import XCTest
@testable import DeerNote

class CoreDataManagerTests: XCTestCase {
    var sut: CoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MockCoreDataManager()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func test_whenInit_mainContextIsNotNil() {
        XCTAssertNotNil(sut.mainContext)
    }
}
