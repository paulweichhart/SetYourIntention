//
//  Action.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

typealias Closure = () -> Void
typealias AsyncClosure = () async -> Void

enum Action {

    case incrementIntention
    case decrementIntention

    case setupInitialState
    case fetchMindfulTimeInterval
    case requestHealthStorePermission
    case startObservingMindfulStoreChanges(AsyncClosure)
    case versionTwoOnboardingCompleted

    case startMeditating
    case stopMeditating
}
