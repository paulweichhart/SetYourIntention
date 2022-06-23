//
//  Store.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 12.06.21.
//

import Combine
import Foundation

final class Store: ObservableObject {

    static let shared = Store()

    @MainActor
    @Published private(set) var state = AppState()

    private var reducer: Reducer = {
        let healthStore = HealthStore()
        let mindfulSession = MindfulSession()
        return Reducer(healthStore: healthStore,
                       mindfulSession: mindfulSession)
    }()

    private init() { }

    @MainActor
    func dispatch(action: Action) async {
        state = await reducer.apply(action: action, to: state)
    }
}
