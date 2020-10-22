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
            if minutes < 0 {
                minutes = 0
            }
            UserDefaults.standard.set(minutes, forKey: "intention")
        }
    }
}
