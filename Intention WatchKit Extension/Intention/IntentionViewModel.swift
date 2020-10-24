//
//  IntentionViewModel.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import Combine
import Foundation
import SwiftUI

final class IntentionViewModel: ObservableObject {
        
    enum State: Equatable {
        case loading
        case mindfulMinutes(Double)
        case error(StoreError)
    }
    
    @Published var state: State = .loading
    @ObservedObject private var store = Store.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    private func subscribe() {
        store.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] storeState in
                switch storeState {
                case .available, .initial:
                    self?.state = .loading
                case let .mindfulMinutes(mindfulMinutes):
                    self?.state = .mindfulMinutes(mindfulMinutes)
                case let .error(error):
                    self?.state = .error(error)
                }
            })
            .store(in: &cancellables)
    }
}
