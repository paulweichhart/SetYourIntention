//
//  Action.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

enum Action {

    case setup
    
    case incrementIntention
    case decrementIntention

    case requestHealthStorePermission
    case fetchMindfulTimeInterval

    case startMeditating
    case stopMeditatingAndFetchMindfulTimeInterval
    case failedStoringMeditatingSession
    case tick

    case guided(Bool)
}
