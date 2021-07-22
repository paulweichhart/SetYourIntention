//
//  Store.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Combine
import Foundation

final class Store: ObservableObject {

    @Published private(set) var state: AppState
    private let reducer: Reducer

    init(initialAppState: AppState, reducer: Reducer) {
        self.state = initialAppState
        self.reducer = reducer
    }

    func dispatch(action: Action) async {
        state = await reducer.apply(action: action, to: state)
    }
}
