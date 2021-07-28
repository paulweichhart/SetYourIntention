//
//  AppState.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

enum ViewState<State: Equatable, StateError: Error> {
    case loading
    case loaded(State)
    case error(StateError)
}

struct AppState {

    private enum Keys: String {
        case intention = "intention"
        case versionOneOnboardingCompleted = "onboardingCompleted"
        case versionTwoOnboardingCompleted = "versionTwoOnboardingCompleted"
    }

    var intention: TimeInterval {
        get {
            return UserDefaults.standard.double(forKey: Keys.intention.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.intention.rawValue)
        }
    }

    var mindfulState: ViewState<TimeInterval, HealthStoreError> = .loading

    var isMeditating: Bool = false

    var versionOneOnboardingCompleted: Bool {
        return UserDefaults.standard.bool(forKey: Keys.versionOneOnboardingCompleted.rawValue)
    }

    var versionTwoOnboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.versionTwoOnboardingCompleted.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.versionTwoOnboardingCompleted.rawValue)
        }
    }

    var progress: Double? {
        switch mindfulState {
        case .loading, .error:
            return nil
        case let .loaded(timeInterval):
            guard timeInterval > 0 && intention > 0 else {
                return 0
            }
            return timeInterval / intention
        }
    }

    var percentage: Int? {
        guard let progress = progress else {
            return nil
        }
        return Int(progress * 100)
    }
}
