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

    var intention: TimeInterval {
        get {
            return UserDefaults.standard.double(forKey: Keys.intention.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.intention.rawValue)
        }
    }

    var mindfulTimeInterval: Result<TimeInterval, HealthStoreError> = .success(0)

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

    var progress: Double {
        switch mindfulTimeInterval {
        case let .success(timeInterval):
            guard timeInterval > 0 && intention > 0 else {
                return 0
            }
            return timeInterval / intention
        case .failure:
            return 0
        }
    }

    var percentage: Int {
        return Int(progress * 100)
    }
}
