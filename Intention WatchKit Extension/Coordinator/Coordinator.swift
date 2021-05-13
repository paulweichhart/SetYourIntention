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
        case onboarding
        case intentionView
        case setIntentionView
    }
    
    struct DestinationView: View {
            
        let destination: Destination
        let intention: Intention
        
        var body: some View {
            switch destination {
            
            case .onboarding:
                let viewModel = PermissionViewModel(intention: intention)
                OnboardingView(viewModel: viewModel)
            
            case .intentionView:
                let viewModel = IntentionViewModel(intention: intention)
                IntentionView(viewModel: viewModel)
                
            case .setIntentionView:
                SetIntentionView(intention: intention)
            }
        }
    }
    
    private let intention: Intention
    
    init(intention: Intention) {
        self.intention = intention
    }
    
    func navigate(to destination: Destination) -> DestinationView {
        return DestinationView(destination: destination, intention: intention)
    }
}
