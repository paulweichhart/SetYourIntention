//
//  ViewState.swift
//  ViewState
//
//  Created by Paul Weichhart on 13.08.21.
//

import Foundation

enum ViewState<State: Equatable, StateError: Error>: Equatable {
    case loading
    case loaded(State)
    case error(StateError)

    static func == (lhs: ViewState<State, StateError>, rhs: ViewState<State, StateError>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.error, .error):
            return true
        case (let .loaded(lhsState), let .loaded(rhsState)):
            return lhsState == rhsState
        default:
            return false
        }
    }
}
