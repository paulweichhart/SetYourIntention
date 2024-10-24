//
//  Action.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

enum Action {
    
    case setupInitialState

    case incrementIntention
    case decrementIntention

    case requestHealthStorePermission
    case fetchMindfulTimeInterval
    
    case presentMeditationSession
    case dismissPresentation

    case migrateToLatestVersion
    case stopMeditating
    case startMeditating
    case failedStoringMeditatingSession
    case notifyUser
    case tick

    case guided(Bool)
}
