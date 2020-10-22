//
//  IntentionViewModel.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import HealthKit
import Foundation
import SwiftUI

final class IntentionViewModel: ObservableObject {
        
    enum State: Equatable {
        case initial
        case loading
        case mindfulMinutes(Double)
        case error(StoreError)
    }
    
    @Published var state: State = .initial
    
    private weak var store: Store?
    
    init(store: Store?) {
        self.store = store
        
        store?.permission(completion: { [weak self] granted in
            switch granted {
            case .success:
                self?.state = .loading
                self?.mindfulMinutes()
            case let .failure(error):
                self?.state = .error(error)
            }
        })
    }
    
    func mindfulMinutes() {
        if state == .initial {
            return
        }
        
        store?.mindfulMinutes(completion: { [weak self] result in
            switch result {
            case let .success(minutes):
                self?.state = .mindfulMinutes(minutes)
            case let .failure(error):
                self?.state = .error(error)
            }
        })
    }
}
