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
        sut = CoreDataManager.shared
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

}
