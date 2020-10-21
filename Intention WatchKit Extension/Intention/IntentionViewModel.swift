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
    
    private weak var store: Store?
    
    init(store: Store?) {
        self.store = store
    }
}
