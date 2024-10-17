//
//  ConverterTests.swift
//  Intention Tests
//
//  Created by Paul Weichhart on 30.09.24.
//

import XCTest

@testable import Intention_Watch_App

final class ConverterTests: XCTestCase {
    
    func testTimeInterval() {
        XCTAssertEqual(Converter.timeInterval(from: -1), -60)
        XCTAssertEqual(Converter.timeInterval(from: 0), 0)
        XCTAssertEqual(Converter.timeInterval(from: 1), 60)
        XCTAssertEqual(Converter.timeInterval(from: 2), 120)
    }
    
    func testMinutes() {
        XCTAssertEqual(Converter.minutes(from: -60), -1)
        XCTAssertEqual(Converter.minutes(from: 0), 0)
        XCTAssertEqual(Converter.minutes(from: 30), 0)
        XCTAssertEqual(Converter.minutes(from: 60), 1)
        XCTAssertEqual(Converter.minutes(from: 120), 2)
        XCTAssertEqual(Converter.minutes(from: 179), 2)
    }
}
