//
//  HealthStore.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 21.10.20.
//

import Foundation
@preconcurrency import HealthKit
import UIKit

enum HealthStoreError: Error, Equatable {
    case noDataAvailable
    case permissionDenied
    case savingFailed
    case unavailable
}

@MainActor
final class HealthStore {

    private var mindfulSession: HKSampleType? {
        return HKObjectType.categoryType(forIdentifier: .mindfulSession)
    }

    private(set) var store: HKHealthStore? = {
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
        let anchorDescriptor = HKAnchoredObjectQueryDescriptor(predicates: [.sample(type: mindfulSession, predicate: predicate)],
                                                               anchor: nil)
        do {
            let samples = try await anchorDescriptor.result(for: store)
            return samples.addedSamples.reduce(0, { seconds, sample in
                return seconds + sample.endDate.timeIntervalSince(sample.startDate)
            })
        } catch {
            throw HealthStoreError.noDataAvailable
        }
    }

    func storeMindfulTimeInterval(startDate: Date, endDate: Date) async throws {
        guard let store = store,
              let mindfulSession = mindfulSession as? HKCategoryType else {
            throw HealthStoreError.unavailable
        }

        let mindfulSample = HKCategorySample(type: mindfulSession,
                                             value: 0 ,
                                             start: startDate,
                                             end: endDate)
        do {
            try await store.save(mindfulSample)
        } catch {
            throw HealthStoreError.savingFailed
        }
    }
}
