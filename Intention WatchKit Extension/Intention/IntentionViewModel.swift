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
        
    var mindfulMinutes = "20"
    @Published var intendedMinutes: Double = 0 {
        willSet {
            UserDefaults.standard.set(newValue, forKey: "intention")
        }
    }
    
    private let store: HKHealthStore?
    
    init(store: HKHealthStore?) {
        self.store = store
        
        permission()
    }
    
    private func permission() {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else {
            return
        }
        let mindfulSession = Set([mindfulType])
        store?.requestAuthorization(toShare: mindfulSession, read: mindfulSession, completion: { success, error in
            if success {
                print("GRANTED")
            }
        })
    }
}
