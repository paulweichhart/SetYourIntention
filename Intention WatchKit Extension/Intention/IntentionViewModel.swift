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
        case minutes(_ minutes: Minutes)
        case error(StoreError)
    }
    
    @Published private(set) var state: State = .loading
    
    private let intention: Intention
    private var cancellable = Set<AnyCancellable>()
    
    init(intention: Intention) {
        self.intention = intention
        
        subscribe()
    }

    // TODO: Fetch on AppDidOpen

    func mindfulMinutes() {
        Publishers.CombineLatest(intention.$minutes.setFailureType(to: StoreError.self),
                                 Store.shared.mindfulMinutes())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] state in
                if case let .failure(error) = state {
                    self?.state = .error(error)
                }
            }, receiveValue: { [weak self] intention, mindfulMinutes in
                let minutes = Minutes(mindful: mindfulMinutes,
                                      intention: intention)
                self?.state = .minutes(minutes)
            })
            .store(in: &cancellable)
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
            .store(in: &cancellable)
    }
}
