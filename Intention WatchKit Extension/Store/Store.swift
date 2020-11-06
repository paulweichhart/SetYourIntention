//
//  Store.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 21.10.20.
//

import Combine
import Foundation
import HealthKit

enum StoreError: Error {
    case permissionDenied
    case unavailable
    case noDataAvailable
}

final class Store: ObservableObject {

    enum State: Equatable {
        case initial
        case available
        case error(StoreError)
    }
    
    static let shared = Store()
    
    @Published private(set) var state: State = .initial
    
    private var store: HKHealthStore?
    private var mindfulSession: HKSampleType? {
        return HKObjectType.categoryType(forIdentifier: .mindfulSession)
    }
    
    private init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.state = .error(.unavailable)
            return
        }
        self.store = HKHealthStore()
        permission()
    }
    
    func permission(completion: ((Bool) -> Void)? = nil) {
        guard let mindfulSession = mindfulSession else {
            state = .error(.unavailable)
            return
        }
        store?.requestAuthorization(toShare: nil, read: Set([mindfulSession]), completion: { [weak self] success, error in
            if success {
                self?.state = .available
                completion?(true)
            } else if let _ = error {
                self?.state = .error(.permissionDenied)
                completion?(false)
            }
        })
    }
    
    func mindfulMinutes(completion: @escaping (Result<Double,StoreError>) -> Void) {
        
        guard let mindfulSession = mindfulSession, state == .available else {
            completion(.failure(.unavailable))
            return
        }
            
        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: mindfulSession, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor], resultsHandler: { _, samples, error in
            if let _ = error {
                completion(.failure(.noDataAvailable))
                return
            }
            let mindfulSeconds = samples?.reduce(0, { seconds, sample in
                return seconds + sample.endDate.timeIntervalSince(sample.startDate)
            }) ?? 0
            DispatchQueue.main.async {
                completion(.success(mindfulSeconds / 60))
            }
        })
        store?.execute(query)
    }
}
