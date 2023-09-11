//
//  Constants.swift
//  Intention
//
//  Created by Paul Weichhart on 09.09.22.
//

import Foundation

enum Constants: String {
    case intention = "intention"
    case guided = "guided"

    case versionOneOnboardingCompleted = "onboardingCompleted"
    case versionTwoOnboardingCompleted = "versionTwoOnboardingCompleted"
    case versionThreeOnboardingCompleted = "versionThreeOnboardingCompleted"

    case complication = "com.paulweichhart.Intention.watchkitapp.ComplicationExtension"
    case appGroup = "group.com.paulweichhart.Intention.appgroup"
}

enum Layout: CGFloat {
    case buttonBorderRadius = 16.0
}

enum Icons: String {
    case minus = "minus"
    case plus = "plus"
    case gear = "gearshape"
    case leaf = "leaf"
    case stats = "chart.bar"
}
