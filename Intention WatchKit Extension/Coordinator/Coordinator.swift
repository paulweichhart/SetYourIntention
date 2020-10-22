//
//  Coordinator.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Foundation
import HealthKit
import SwiftUI

final class Coordinator {
    
    enum Destination {
        case intentionView
        case editIntentionView
    }
    
    struct DestinationView: View {
            
        let destination: Destination
        weak var store: Store?
        
        var body: some View {
            switch destination {
            
            case .intentionView:
                let viewModel = IntentionViewModel(store: store)
                IntentionView(viewModel: viewModel)
                
            case .editIntentionView:
                EditIntentionView()
            }
        }
    }
    
    private weak var store: Store?
    
    init(store: Store) {
        self.store = store
    }
    
    func navigate(to destination: Destination) -> DestinationView {
        return DestinationView(destination: destination, store: store)
    }
}
