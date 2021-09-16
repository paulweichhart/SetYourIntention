//
//  UnitTests.swift
//  UnitTests
//
//  Created by Paul Weichhart on 17.07.21.
//

import XCTest
@testable import Intention_WatchKit_Extension

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

    func testViewState() {
        let loadingState: ViewState<TimeInterval, HealthStoreError> = .loading
        let loadedState: ViewState<TimeInterval, HealthStoreError> = .loaded(100)
        let anotherLoadedState: ViewState<TimeInterval, HealthStoreError> = .loaded(200)
        let errorState: ViewState<TimeInterval, HealthStoreError> = .error(.unavailable)
        let anotherErrorState: ViewState<TimeInterval, HealthStoreError> = .error(.noDataAvailable)

        XCTAssertTrue(loadingState == loadingState)
        XCTAssertTrue(loadedState == loadedState)
        XCTAssertTrue(errorState == errorState)
        XCTAssertTrue(errorState == anotherErrorState)

        XCTAssertFalse(loadingState == errorState)
        XCTAssertFalse(loadedState == loadingState)
        XCTAssertFalse(loadingState == anotherLoadedState)
        XCTAssertFalse(loadingState == errorState)
    }
}
