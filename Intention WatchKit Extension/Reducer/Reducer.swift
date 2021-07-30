//
//  Reducer.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

struct Reducer {

    private let defaultTimeInterval: TimeInterval = Converter.timeInterval(from: 5)
    private let healthStore: HealthStore
    
    init(healthStore: HealthStore) {
        self.healthStore = healthStore
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
            state.isMeditating = true
            
        case .stopMeditating:
            state.isMeditating = false
        }

        return state
    }
}
