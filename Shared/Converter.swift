//
//  Converter.swift
//  Converter
//
//  Created by Paul Weichhart on 17.07.21.
//

import Foundation

enum Converter {

    static func timeInterval(from minutes: Int) -> TimeInterval {
        let measurement = Measurement(value: Double(minutes), unit: UnitDuration.minutes)
        return measurement.converted(to: .seconds).value
    }

    static func minutes(from timeInterval: TimeInterval) -> Int {
        let measurement = Measurement(value: timeInterval, unit: UnitDuration.seconds)
        return Int(measurement.converted(to: .minutes).value)
    }

    static func progress(mindfulTimeInterval: TimeInterval, intentionTimeInterval: TimeInterval) -> Double {
        guard mindfulTimeInterval > 0 && intentionTimeInterval > 0 else {
            return 0
        }
        return Double(Converter.minutes(from: mindfulTimeInterval)) / Double(Converter.minutes(from: intentionTimeInterval))
    }

    static func percentage(progress: Double) -> Int {
        return Int(progress * 100)
    }
}
