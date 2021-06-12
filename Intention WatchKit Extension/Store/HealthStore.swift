//
//  HealthStore.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 21.10.20.
//

import Combine
import Foundation
import HealthKit

enum HealthStoreError: Error {
    case permissionDenied
    case unavailable
    case noDataAvailable
}

final class HealthStore: ObservableObject {

    enum State: Equatable {
        case initial
        case available
        case error(HealthStoreError)
    }
    
    static let shared = HealthStore()
    
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
    
    private func permission() {
        guard let mindfulSession = mindfulSession else {
            state = .error(.unavailable)
            return
        }
        store?.requestAuthorization(toShare: nil, read: Set([mindfulSession]), completion: { [weak self] success, error in
            if success {
                self?.state = .available
            } else if let _ = error {
                self?.state = .error(.permissionDenied)
            }
        })
    }

    func mindfulMinutes() -> Future<Double, HealthStoreError> {
        return Future { [weak self] promise in
            guard let mindfulSession = self?.mindfulSession, self?.state == .available else {
                promise(.failure(.unavailable))
                return
            }

            let startDate = Calendar.current.startOfDay(for: Date())
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

            let query = HKSampleQuery(sampleType: mindfulSession, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor], resultsHandler: { _, samples, error in
                if let _ = error {
                    promise(.failure(.noDataAvailable))
                    return

                }
                let mindfulSeconds = samples?.reduce(0, { seconds, sample in
                    return seconds + sample.endDate.timeIntervalSince(sample.startDate)
                }) ?? 0
                promise(.success(mindfulSeconds / 60))
            })
            self?.store?.execute(query)
        }
    }
}
