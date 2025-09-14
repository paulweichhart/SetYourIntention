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

    func apply(action: Action, to state: AppState) async -> AppState {
        var state = state
        switch action {
            
            // MARK: - Setup

            case .setup:
                if state.versionState.shouldMigrateFromVersionOne {
                    // Convert from Double to TimeInterval
                    state.intention = Converter.timeInterval(from: Int(state.intention))
                    state.versionState.versionTwoOnboardingCompleted = true
                    state.versionState.versionThreeOnboardingCompleted = true

                } else if state.versionState.shouldShowOnboarding {
                    state.versionState.versionTwoOnboardingCompleted = true
                    state.versionState.versionThreeOnboardingCompleted = true
                    state.intention = 2 * defaultTimeInterval

                } else if state.versionState.shouldMigrateFromVersionTwo {
                    // Store values from UserDefaults in AppGroup
                    state.guided = UserDefaults.standard.bool(forKey: Constants.guided.rawValue)
                    state.intention = UserDefaults.standard.double(forKey: Constants.intention.rawValue)
                    state.versionState.versionThreeOnboardingCompleted = true
                }
                state.app = .loading
            
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
                let timeInterval = try await healthStore.fetchMindfulTimeInterval()
                state.app = .mindfulState(timeInterval)
            } catch {
                let healthStoreError = error as? HealthStoreError ?? .unavailable
                state.app = .error(healthStoreError)
            }

        case .requestHealthStorePermission:
            do {
                try await healthStore.requestPermission()
            } catch {
                state.app = .error(.permissionDenied)
            }

        // MARK: - Mindful Session

        case .startMeditating:
            let startDate = mindfulSession.startSession()
            state.app = .meditating(startDate)

        case .stopMeditatingAndFetchMindfulTimeInterval:
            if case let .meditating(startDate) = state.app {
                do {
                    let endDate = mindfulSession.stopSession()
                    try await healthStore.storeMindfulTimeInterval(startDate: startDate,
                                                                   endDate: endDate)
                    let timeInterval = try await healthStore.fetchMindfulTimeInterval()
                    state.app = .mindfulState(timeInterval)
                } catch {
                    state.app = .error(.savingFailed)
                }
            }

        case .failedStoringMeditatingSession:
            state.app = .error(.savingFailed)

        case .tick:
            if case let .meditating(startDate) = state.app {
                let timeInterval = floor(Date().timeIntervalSince(startDate))
                if timeInterval == state.intention {
                    WKInterfaceDevice.current().play(.success)
                } else if state.guided && timeInterval.truncatingRemainder(dividingBy: Converter.timeInterval(from: 1)) == 0 && timeInterval > 0 {
                    WKInterfaceDevice.current().play(.click)
                }
            }

        case let .guided(guided):
            state.guided = guided
            WKInterfaceDevice.current().play(.click)

        }

        return state
    }
}
