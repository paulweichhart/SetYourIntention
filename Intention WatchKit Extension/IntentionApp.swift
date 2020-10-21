//
//  IntentionApp.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import HealthKit
import SwiftUI
import WatchKit

@main
struct IntentionApp: App {
    
    private let store = Store()
    private let intention = Intention()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                let coordinator = Coordinator(store: store)
                
                switch store.state {
                case let .error(error):
                    coordinator.navigate(to: .errorState(error))
                default:
                    coordinator.navigate(to: .intentionView)
                    coordinator.navigate(to: .editIntentionView)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .environmentObject(intention)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
