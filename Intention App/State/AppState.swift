//
//  AppState.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

struct AppState {

    private let sharedUserDefaults = UserDefaults(suiteName: Constants.appGroup.rawValue)

    // Version State

    var versionAssistant = VersionAssistant()

    // Intention State

    var intention: TimeInterval {
        get {
            return sharedUserDefaults?.double(forKey: Constants.intention.rawValue) ?? 0
        }
        set {
            sharedUserDefaults?.set(newValue, forKey: Constants.intention.rawValue)
        }
    }

    // Guided State

    var guided: Bool {
        get {
            return sharedUserDefaults?.bool(forKey: Constants.guided.rawValue) ?? false
        }
        set {
            sharedUserDefaults?.set(newValue, forKey: Constants.guided.rawValue)
        }
    }

    // Mindful State

    var mindfulState: ViewState<TimeInterval, HealthStoreError> = .loading

    // Mindful Session State

    var mindfulSessionState: MindfulSessionState = .initial
}


