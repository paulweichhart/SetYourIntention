//
//  HealthStore.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 21.10.20.
//

import Foundation
import HealthKit

enum HealthStoreError: Error {
    case permissionDenied
    case unavailable
    case noDataAvailable
}

struct HealthStore {

    private var mindfulSession: HKSampleType? {
        return HKObjectType.categoryType(forIdentifier: .mindfulSession)
    }

    private var store: HKHealthStore? = {
        guard HKHealthStore.isHealthDataAvailable() else {
            return nil
        }
        return HKHealthStore()
    }()
    
    func requestPermission() async throws {
        guard let store = store, let mindfulSession = mindfulSession else {
            throw HealthStoreError.unavailable
        }

        do {
            try await store.requestAuthorization(toShare: Set([mindfulSession]),
                                                 read: Set([mindfulSession]))
        } catch {
            throw HealthStoreError.permissionDenied
        }
    }

    func fetchMindfulTimeInterval() async throws -> TimeInterval {
        guard let store = store, let mindfulSession = mindfulSession else {
            throw HealthStoreError.unavailable
        }

        let startDate = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: mindfulSession, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor], resultsHandler: { _, samples, error in
                if let _ = error {
                    continuation.resume(throwing: HealthStoreError.noDataAvailable)
                }
                let mindfulTimeInterval = samples?.reduce(0, { seconds, sample in
                    return seconds + sample.endDate.timeIntervalSince(sample.startDate)
                }) ?? 0
                continuation.resume(returning: mindfulTimeInterval)
            })
            store.execute(query)
        }
    }
}
