//
//  IntentionApp.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import SwiftUI
import WatchKit

@main
struct IntentionApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    
    private let intention = Intention()
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            TabView {
                let coordinator = Coordinator()
                
                coordinator.navigate(to: .intentionView)
                coordinator.navigate(to: .editIntentionView)
            }
            .tabViewStyle(PageTabViewStyle())
            .environmentObject(intention)
        }
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
