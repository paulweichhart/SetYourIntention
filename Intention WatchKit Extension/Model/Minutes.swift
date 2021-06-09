//
//  Progress.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 11.04.21.
//

import Foundation

struct Minutes: Equatable {

    let mindful: Double
    let intention: Double

    var progress: Double {
        guard mindful > 0 && intention > 0 else {
            return 0
        }
        return mindful / intention
    }

    var percentage: Int {
        return Int(progress * 100)
    }

    var fraction: Float {
        return min(Float(mindful / intention), 1)
    }
}
