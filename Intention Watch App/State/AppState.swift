//
//  AppState.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

struct AppState: Equatable {
    
    enum State: Equatable {
        case loading
        case onboarding
        case meditating(Date)
        case mindfulState(TimeInterval)
        case error(HealthStoreError)
    }
    
    private let sharedUserDefaults = UserDefaults(suiteName: Constants.appGroup.rawValue)
    
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
    
    // Version State
    var versionState: VersionState
    
    // App State
    var app: State
    
    init(versionState: VersionState) {
        self.versionState = versionState
        self.app = versionState.shouldShowOnboarding ? .onboarding : .loading
    }
}
