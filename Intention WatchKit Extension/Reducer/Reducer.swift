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
        case .incrementIntention:
            switch state.intention {
            case 1...10:
                state.intention += smallTimeInterval
            case 11..<90:
                state.intention += defaultTimeInterval
            default:
                break
            }

        case .decrementIntention:
            switch state.intention {
            case 2...10:
                state.intention -= smallTimeInterval
            case 11..<90:
                state.intention -= defaultTimeInterval
            default:
                break
            }
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
            let now = Date()
            if case let .meditating(startDate) = state.mindfulSessionState, startDate.addingTimeInterval(state.intention) >= now && startDate.addingTimeInterval(state.intention + 1.0) <= now {
                WKInterfaceDevice.current().play(.success)
            }
        }

        return state
    }
}
