//
//  VersionAssistant.swift
//  Intention
//
//  Created by Paul Weichhart on 12.09.22.
//

import Foundation

struct VersionAssistant {

    private let sharedUserDefaults = UserDefaults(suiteName: Constants.appGroup.rawValue)

    // Version 1.0 is using the wrong format
    var shouldMigrateFromVersionOne: Bool {
        return versionOneOnboardingCompleted && versionTwoOnboardingCompleted == false
    }

    // Starting from Version 2.0 App is reading & writing to HealthStore
    var shouldShowOnboarding: Bool {
        return versionTwoOnboardingCompleted == false && versionThreeOnboardingCompleted == false
    }

    // Version 3.0 introduced AppGroup
    var shouldMigrateFromVersionTwo: Bool {
        return versionTwoOnboardingCompleted && versionThreeOnboardingCompleted == false
    }

    // MARK: Versions

    var versionOneOnboardingCompleted: Bool {
        return UserDefaults.standard.bool(forKey: Constants.versionOneOnboardingCompleted.rawValue)
    }

    var versionTwoOnboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Constants.versionTwoOnboardingCompleted.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.versionTwoOnboardingCompleted.rawValue)
        }
    }

    var versionThreeOnboardingCompleted: Bool {
        get {
            return sharedUserDefaults?.bool(forKey: Constants.versionThreeOnboardingCompleted.rawValue) ?? false
        }
        set {
            sharedUserDefaults?.set(newValue, forKey: Constants.versionThreeOnboardingCompleted.rawValue)
        }
    }
}
