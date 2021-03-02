//
//  Intention.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Combine
import Foundation

final class Intention: ObservableObject {
    
    private enum Keys: String {
        case intention = "intention"
        case onboardingCompleted = "onboardingCompleted"
    }
    
    @Published var minutes: Double = UserDefaults.standard.double(forKey: Keys.intention.rawValue) {
        didSet {
            UserDefaults.standard.set(minutes, forKey: Keys.intention.rawValue)
        }
    }
    
    @Published var onboardingCompleted: Bool = UserDefaults.standard.bool(forKey: Keys.onboardingCompleted.rawValue) {
        didSet {
            UserDefaults.standard.set(onboardingCompleted, forKey: Keys.onboardingCompleted.rawValue)
        }
    }
    
    private let defaultMinutes: Double = 5
    private let maxMinutes: Double = 90
    
    init() {
        if minutes == 0 {
            minutes = 2 * defaultMinutes
        }
    }
    
    func increment() {
        if minutes < maxMinutes {
            minutes += defaultMinutes
        }
    }
    
    func decrement() {
        if minutes > defaultMinutes {
            minutes -= defaultMinutes
        }
    }
}
