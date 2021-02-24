//
//  Intention.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Combine
import Foundation

final class Intention: ObservableObject {
    
    @Published var minutes: Double = UserDefaults.standard.double(forKey: "intention") {
        didSet {
            UserDefaults.standard.set(minutes, forKey: "intention")
        }
    }
    
    @Published var onboardingCompleted: Bool = UserDefaults.standard.bool(forKey: "onboardingCompleted") {
        didSet {
            UserDefaults.standard.set(onboardingCompleted, forKey: "onboardingCompleted")
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
