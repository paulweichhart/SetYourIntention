//
//  IntentionUITests.swift
//  Intention UI Tests
//
//  Created by Paul Weichhart on 30.09.24.
//

import XCTest

@testable import Intention_Watch_App

@MainActor
final class IntentionUITests: XCTestCase {
    
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        throw XCTSkip("Skipped for now")
    }

    @MainActor
    func testOnboarding() throws {
        // UI tests must launch the application that they test.
        
        app.launch()
        
        onboarding()
    }
    
    private func onboarding() {
        XCTAssertTrue(app.staticTexts["Set Your Intention"].exists)
        app.scrollViews.otherElements.firstMatch.swipeLeft()
        
        XCTAssertTrue(app.staticTexts["Keep track of your daily Mindful Minutes with the supported Complications on your Apple Watch"].exists)
        app.scrollViews.otherElements.firstMatch.swipeLeft()
        
        XCTAssertTrue(app.staticTexts["Review"].exists)
        app.buttons["Review"].firstMatch.tap()
    }
}
