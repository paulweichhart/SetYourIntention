//
//  IntentionApp.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import Combine
import Foundation
import SwiftUI
import WatchKit

@main
struct IntentionApp: App {
    
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var delegate
    @ObservedObject private var intention = Intention()
    
    @SceneBuilder var body: some Scene {
        
        let coordinator = Coordinator(intention: intention)
        
        WindowGroup {
            switch intention.onboardingCompleted {
            case true:
                TabView {
                    coordinator.navigate(to: .intentionView)
                    coordinator.navigate(to: .setIntentionView)
                }
                .tabViewStyle(PageTabViewStyle())
            case false:
                coordinator.navigate(to: .onboarding)
            }
        }
    }
}
