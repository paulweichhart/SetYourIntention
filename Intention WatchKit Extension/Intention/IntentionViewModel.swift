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
    
    func mindfulMinutes() {
        Store.shared.fetchMindfulMinutes()
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
                    Store.shared.fetchMindfulMinutes()

                case let .error(error):
                    self?.state = .error(error)
                }
            })
            .store(in: &cancellable)

        Publishers.CombineLatest(intention.$minutes, Store.shared.$mindfulMinutes)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] intention, mindfulResult in
                switch mindfulResult {
                case let .failure(storeError):
                    self?.state = .error(storeError)

                case let .success(mindfulMinutes):
                    let minutes = Minutes(mindful: mindfulMinutes,
                                          intention: intention)
                    self?.state = .minutes(minutes)

                case .none:
                    self?.state = .error(.noDataAvailable)
                }
            })
            .store(in: &cancellable)
    }
}
