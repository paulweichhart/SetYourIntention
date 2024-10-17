//
//  Store.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Foundation

@MainActor
final class Store: ObservableObject {

    static let shared = Store()

    @Published private(set) var state = AppState()

    private var reducer: Reducer = {
        let healthStore = HealthStore()
        let mindfulSession = MindfulSession()
        return Reducer(healthStore: healthStore,
                       mindfulSession: mindfulSession)
    }()

    private init() { }

    func dispatch(action: Action) async {
        state = await reducer.apply(action: action, to: state)
    }
}
