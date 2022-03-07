//
//  GradationColorsTests.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 2/3/22.
//

import XCTest
@testable import DeerNote

class GradationColorTest: XCTestCase {
    var sut: GradationColor!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = GradationColor()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testInit_colorTableHasTwleveBasicColor() {
        let basicColorCount: Int = 12
        XCTAssertEqual(basicColorCount, sut.getTotalColorCount())
    }
    
    func test_append_whenCall_colorTableAppendColor() {
        let beforeColorCount: Int = sut.getTotalColorCount()
        
        sut.append(fromColor: .orange, toColor: .red)
        
        let afterColorCount: Int = sut.getTotalColorCount()
        XCTAssertEqual(beforeColorCount + 1, afterColorCount)
    }
}
