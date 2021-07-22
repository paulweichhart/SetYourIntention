//
//  Action.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

enum Action {

    case incrementIntention
    case decrementIntention

    case setupInitialState
    case fetchMindfulTimeInterval
    case requestHealthStorePermission
    case versionTwoOnboardingCompleted
}
