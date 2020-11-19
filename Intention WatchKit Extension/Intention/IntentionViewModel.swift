//
//  IntentionViewModel.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import Combine
import Foundation

final class IntentionViewModel: ObservableObject {
        
    enum State: Equatable {
        case loading
        case mindfulMinutes(Double)
        case error(StoreError)
    }
    
    @Published var state: State = .loading
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    func mindfulMinutes() {
        Store.shared.mindfulMinutes(completion: { [weak self] result in
            switch result {
            case let .success(mindfulMinutes):
                self?.state = .mindfulMinutes(mindfulMinutes)
            case let .failure(error):
                self?.state = .error(error)
            }
        })
    }
    
    private func subscribe() {
        Store.shared.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] storeState in
                switch storeState {
                case .initial:
                    self?.state = .loading
                    
                case .available:
                    self?.state = .loading
                    self?.mindfulMinutes()
                    
                case let .error(error):
                    self?.state = .error(error)
                }
            })
            .store(in: &cancellables)
    }
}
