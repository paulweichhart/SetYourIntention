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
    
    private let coordinator = Coordinator()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                if HKHealthStore.isHealthDataAvailable() {
                    coordinator.navigate(to: .intentionView)
                    coordinator.navigate(to: .editView)
                } else {
                    Text("Oh noes")
                }
            }
            .tabViewStyle(PageTabViewStyle())
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
