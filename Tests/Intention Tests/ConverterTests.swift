//
//  ConverterTests.swift
//  Intention Tests
//
//  Created by Paul Weichhart on 30.09.24.
//

import Testing

@testable import Intention_Watch_App

struct ConverterTests {

    @Test func timeInterval() {
        #expect(Converter.timeInterval(from: -1) == -60)
        #expect(Converter.timeInterval(from: 0) == 0)
        #expect(Converter.timeInterval(from: 1) == 60)
        #expect(Converter.timeInterval(from: 2) == 120)
    }

    @Test func minutes() {
        #expect(Converter.minutes(from: -60) == -1)
        #expect(Converter.minutes(from: 0) == 0)
        #expect(Converter.minutes(from: 30) == 0)
        #expect(Converter.minutes(from: 60) == 1)
        #expect(Converter.minutes(from: 120) == 2)
        #expect(Converter.minutes(from: 179) == 2)
    }
}
