//
//  Reducer.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation
import HealthKit

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

        case let .startObservingMindfulStoreChanges(storeDidChange):
            try? await healthStore.registerMindfulObserver(storeDidChange: storeDidChange)

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
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = .mindAndBody
            configuration.locationType = .indoor

            do {
                state.session = try HKWorkoutSession(healthStore: healthStore.store!, configuration: configuration)
//                state.builder = state.session?.associatedWorkoutBuilder()
//                state.builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore.store!,
//                                                                    workoutConfiguration: configuration)
                let startDate = Date()
                state.session?.startActivity(with: startDate)
                try await state.builder?.beginCollection(at: startDate)
                state.isMeditating = true
            } catch {
                // Use View State
            }

        case .stopMeditating:
            state.session?.end()
            state.isMeditating = false
            state.builder = nil
            state.session = nil
        }

        return state
    }
}
