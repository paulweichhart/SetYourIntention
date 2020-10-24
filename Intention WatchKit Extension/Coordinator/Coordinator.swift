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
        
        var body: some View {
            switch destination {
            
            case .intentionView:
                let viewModel = IntentionViewModel()
                IntentionView(viewModel: viewModel)
                
            case .editIntentionView:
                EditIntentionView()
            }
        }
    }
    
    func navigate(to destination: Destination) -> DestinationView {
        return DestinationView(destination: destination)
    }
}
