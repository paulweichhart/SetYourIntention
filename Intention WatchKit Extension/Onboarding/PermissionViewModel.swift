//
//  PermissionViewModel.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 03.05.21.
//

import Combine
import Foundation

final class PermissionViewModel: ObservableObject {

    private let intention: Intention
    private var cancellable = Set<AnyCancellable>()

    init(intention: Intention) {
        self.intention = intention
    }

    func initialiseStore() {
        let store = Store.shared
        store.$state
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] storeState in
                if case .available = storeState {
                    self?.intention.onboardingCompleted = true
                }
            })
            .store(in: &cancellable)
    }


}
