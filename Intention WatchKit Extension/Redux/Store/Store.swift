//
//  Store.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Combine
import Foundation

@MainActor
final class Store: ObservableObject {

    static let shared = Store()

    @Published private(set) var state = AppState()

    private var reducer: Reducer = {
        let healthStore = HealthStore()
        return Reducer(healthStore: healthStore)
    }()

    private init() { }

    func dispatch(action: Action) async {
        state = await reducer.apply(action: action, to: state)
    }
}
