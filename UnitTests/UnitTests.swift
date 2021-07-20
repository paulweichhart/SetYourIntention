//
//  UnitTests.swift
//  UnitTests
//
//  Created by Paul Weichhart on 17.07.21.
//

import XCTest

class UnitTests: XCTestCase {

    func testConverter() throws {
        for minutes in 1...90 {
            let timeInterval = Double(minutes) * 60.0
            let value = Converter.minutes(from: timeInterval)
            XCTAssertEqual(value, minutes)
        }

        XCTAssertEqual(Converter.minutes(from: 59), 0)
        XCTAssertEqual(Converter.minutes(from: 61), 1)
        XCTAssertEqual(Converter.minutes(from: 119.9), 1)
        XCTAssertEqual(Converter.minutes(from: 120.1), 2)
    }
}
