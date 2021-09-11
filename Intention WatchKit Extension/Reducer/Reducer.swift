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
    private let healthStore: HealthStore
    private let mindfulSession: MindfulSession

    init(healthStore: HealthStore, mindfulSession: MindfulSession) {
        self.healthStore = healthStore
        self.mindfulSession = mindfulSession
    }

    func apply(action: Action, to state: AppState) async -> AppState {
        var state = state
        switch action {
        case .incrementIntention:
            if state.intention < Converter.timeInterval(from: 90) {
                state.intention += defaultTimeInterval
            }

        case .decrementIntention:
            if state.intention > Converter.timeInterval(from: 5) {
                state.intention -= defaultTimeInterval
            }

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

        case let .startObservingMindfulStoreChanges(storeDidChange):
            if !state.didRegisterBackgroundDelivery && state.versionTwoOnboardingCompleted {
                try? await healthStore.registerMindfulObserver(storeDidChange: storeDidChange)
                state.didRegisterBackgroundDelivery = true
            }

        case .setupInitialState:
            if state.versionOneOnboardingCompleted && !state.versionTwoOnboardingCompleted {
                // Convert from Double to TimeInterval
                state.intention = Converter.timeInterval(from: Int(state.intention))
            } else if !state.versionOneOnboardingCompleted && !state.versionTwoOnboardingCompleted {
                state.intention = 2 * defaultTimeInterval
            }

        case .versionTwoOnboardingCompleted:
            state.versionTwoOnboardingCompleted = true

        case .startMeditating:
            let startDate = mindfulSession.startSession(with: state.intention)
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
        case .intentionAchieved:
            mindfulSession.notifyUser(success: true)

        case .failedStoringMeditatingSession:
            state.mindfulSessionState = .error(.savingFailed)
            
        }

        return state
    }
}
