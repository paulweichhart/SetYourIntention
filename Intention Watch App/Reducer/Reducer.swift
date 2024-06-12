//
//  Reducer.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation
import WatchKit
import SwiftUI

struct Reducer {

    private let defaultTimeInterval: TimeInterval = Converter.timeInterval(from: 5)
    private let smallTimeInterval: TimeInterval = Converter.timeInterval(from: 1)
    
    private let healthStore: HealthStore
    private let mindfulSession: MindfulSession

    init(healthStore: HealthStore, mindfulSession: MindfulSession) {
        self.healthStore = healthStore
        self.mindfulSession = mindfulSession
    }

    @MainActor
    func apply(action: Action, to state: AppState) async -> AppState {
        var state = state
        switch action {

        // MARK: - Set Intention

        case .incrementIntention:
            switch state.intention {
            case Converter.timeInterval(from: 1)..<Converter.timeInterval(from: 10):
                state.intention += smallTimeInterval
                WKInterfaceDevice.current().play(.click)
            case Converter.timeInterval(from: 10)..<Converter.timeInterval(from: 90):
                state.intention += defaultTimeInterval
                WKInterfaceDevice.current().play(.click)
            default:
                break
            }

        case .decrementIntention:
            switch state.intention {
            case Converter.timeInterval(from: 2)...Converter.timeInterval(from: 10):
                state.intention -= smallTimeInterval
                WKInterfaceDevice.current().play(.click)
            case Converter.timeInterval(from: 10)...Converter.timeInterval(from: 90):
                state.intention -= defaultTimeInterval
                WKInterfaceDevice.current().play(.click)
            default:
                break
            }

        // MARK: - Fetch from Store

        case .fetchMindfulTimeInterval:
            do {
                try await healthStore.requestPermission()
                let timeInterval = try await healthStore.fetchMindfulTimeInterval()
                state.mindfulState = .loaded(timeInterval)
            } catch {
                let healthStoreError = error as? HealthStoreError ?? .unavailable
                state.mindfulState = .error(healthStoreError)
            }

        case .requestHealthStorePermission:
            do {
                try await healthStore.requestPermission()
            } catch {
                state.mindfulState = .error(.permissionDenied)
            }

        // MARK: - Migration

        case .migrateToLatestVersion:
            if state.versionAssistant.shouldMigrateFromVersionOne {
                // Convert from Double to TimeInterval
                state.intention = Converter.timeInterval(from: Int(state.intention))
                state.versionAssistant.versionTwoOnboardingCompleted = true
                state.versionAssistant.versionThreeOnboardingCompleted = true

            } else if state.versionAssistant.shouldShowOnboarding {
                // Set initial State
                state.intention = 2 * defaultTimeInterval
                state.versionAssistant.versionTwoOnboardingCompleted = true
                state.versionAssistant.versionThreeOnboardingCompleted = true

            } else if state.versionAssistant.shouldMigrateFromVersionTwo {
                // Store values from UserDefaults in AppGroup
                state.guided = UserDefaults.standard.bool(forKey: Constants.guided.rawValue)
                state.intention = UserDefaults.standard.double(forKey: Constants.intention.rawValue)
                state.versionAssistant.versionThreeOnboardingCompleted = true
            }

        // MARK: - Mindful Session

        case .startMeditating:
            let startDate = mindfulSession.startSession()
            state.mindfulSessionState = .meditating(startDate)

        case .stopMeditating:
            if case let .meditating(startDate) = state.mindfulSessionState {
                do {
                    let endDate = mindfulSession.stopSession()
                    try await healthStore.storeMindfulTimeInterval(startDate: startDate,
                                                                   endDate: endDate)
                    state.mindfulSessionState = .initial
                } catch {
                    state.mindfulSessionState = .error(.savingFailed)
                }
            }

        case .failedStoringMeditatingSession:
            state.mindfulSessionState = .error(.savingFailed)

        case .notifyUser:
            WKInterfaceDevice.current().play(.success)

        case .tick:
            if case let .meditating(startDate) = state.mindfulSessionState {
                let timeInterval = floor(Date().timeIntervalSince(startDate))
                if timeInterval == state.intention {
                    WKInterfaceDevice.current().play(.success)
                } else if state.guided && timeInterval.truncatingRemainder(dividingBy: Converter.timeInterval(from: 1)) == 0 && timeInterval > 0 {
                    WKInterfaceDevice.current().play(.start)
                }
            }

        case let .guided(guided):
            state.guided = guided
            WKInterfaceDevice.current().play(.click)

        }

        return state
    }
}
