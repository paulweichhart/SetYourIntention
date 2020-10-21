//
//  Store.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 21.10.20.
//

import Foundation
import HealthKit


final class Store {

    enum StoreError: Error {
        case permissionDenied
        case unavailable
    }
    
    enum State {
        case initial
        case available(Double? = nil)
        case error(StoreError)
    }
    
    private(set) var state: State = .initial {
        didSet {
            if case .error = state {
                store = nil
            }
        }
    }
    
    private var store: HKHealthStore?
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.state = .error(.unavailable)
            return
        }
        self.store = HKHealthStore()
        
        askForPermission(completion: { [weak self] state in
            self?.state = state
        })
    }
    
    func mindfulMinutes(completion: @escaping ((Result<Double, StoreError>) -> Void)) {
        if case let .error(error) = state {
            completion(.failure(error))
            return
        }
        
        // fetch mindful minutes
    }
    
    private func askForPermission(completion: @escaping ((State) -> Void)) {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            completion(.error(.unavailable))
            return
        }
        store?.requestAuthorization(toShare: nil, read: Set([mindfulType]), completion: { success, error in
            if success {
                completion(.available())
            } else if let _ = error {
                completion(.error(.permissionDenied))
            }
        })
    }
}
