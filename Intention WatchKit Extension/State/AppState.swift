//
//  AppState.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

struct AppState {

    private enum Keys: String {
        case intention = "intention"
        case versionOneOnboardingCompleted = "onboardingCompleted"
        case versionTwoOnboardingCompleted = "versionTwoOnboardingCompleted"
    }

    // Version State

    var didRegisterBackgroundDelivery: Bool = false

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

    // Intention State

    var intention: TimeInterval {
        get {
            return UserDefaults.standard.double(forKey: Keys.intention.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.intention.rawValue)
        }
    }

    // Mindful State

    var mindfulState: ViewState<TimeInterval, HealthStoreError> = .loading

    var mindfulStateProgress: Double? {
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

    var mindfulStatePercentage: Int? {
        guard let progress = mindfulStateProgress else {
            return nil
        }
        return Int(progress * 100)
    }

    // Mindful Session State

    var mindfulSessionState: MindfulSessionState = .initial

    var mindfulSessionProgress: Double? {
        switch mindfulSessionState {
        case .initial, .error:
            return nil
        case let .meditating(startDate):
            guard intention > 0 else {
                return 0
            }
            return Date().timeIntervalSince(startDate) / intention
        }
    }

    var mindfulSessionPercentage: Int? {
        guard let progress = mindfulSessionProgress else {
            return nil
        }
        return Int(progress * 100)
    }

}
