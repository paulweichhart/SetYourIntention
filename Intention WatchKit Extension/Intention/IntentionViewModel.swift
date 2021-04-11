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
    private var cancellables = Set<AnyCancellable>()
    
    init(intention: Intention) {
        self.intention = intention
        
        subscribe()
    }
    
    func mindfulMinutes() {
        Store.shared.mindfulMinutes()
    }

    private func subscribe() {
        Publishers.CombineLatest(Store.shared.$state, intention.$minutes)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] storeState, intentionMinutes in
                switch storeState {
                case .initial:
                    self?.state = .loading

                case .available:
                    self?.state = .loading
                    self?.mindfulMinutes()

                case let .mindfulMinutes(mindfulMinutes):
                    let minutes = Minutes(mindful: mindfulMinutes,
                                          intention: intentionMinutes)
                    self?.state = .minutes(minutes)

                case let .error(error):
                    self?.state = .error(error)
                }
            })
            .store(in: &cancellables)
    }
}
