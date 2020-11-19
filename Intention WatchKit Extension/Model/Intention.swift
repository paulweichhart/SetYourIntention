//
//  Intention.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Combine
import Foundation

final class Intention: ObservableObject {
    
    private let defaultMinutes: Double = 5
    private let maxMinutes: Double = 90
    
    @Published var mindfulMinutes: Double = UserDefaults.standard.double(forKey: "intention") {
        didSet {
            UserDefaults.standard.set(mindfulMinutes, forKey: "intention")
        }
    }
    
    init() {
        if mindfulMinutes == 0 {
            mindfulMinutes = 2 * defaultMinutes
        }
    }
    
    func increment() {
        if mindfulMinutes < maxMinutes {
            mindfulMinutes += defaultMinutes
        }
    }
    
    func decrement() {
        if mindfulMinutes > defaultMinutes {
            mindfulMinutes -= defaultMinutes
        }
    }
}
