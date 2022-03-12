//
//  CommonDecodableTests.swift
//  DeerNoteTests
//
//  Created by JunHeeJo on 3/12/22.
//

import XCTest
@testable import DeerNote

class CommonDecodableTests<ModelType: Decodable>: XCTestCase {
    
    var sut: ModelType!
    var decoder: JSONDecoder!
    var data: Data!

    override func setUpWithError() throws {
        try super.setUpWithError()
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        decoder = nil
        data = nil
        sut = nil
    }
    
    func test_shouldConformDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }
    
    func testDecoding() throws {
        let url = Bundle(for: Self.self).url(forResource: "\(ModelType.self)", withExtension: "json")!
        data = try Data(contentsOf: url)
        
        XCTAssertNoThrow(try decoder.decode([ModelType].self, from: data))
    }
}
