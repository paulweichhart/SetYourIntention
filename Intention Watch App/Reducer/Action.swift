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

    case migrateToLatestVersion

    case requestHealthStorePermission
    case fetchMindfulTimeInterval

    case startMeditating
    case stopMeditating
    case failedStoringMeditatingSession
    case notifyUser
    case tick

    case guided(Bool)
}
