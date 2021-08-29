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
    private let store = Store.shared

    var body: some Scene {

        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

struct RootView: View {

    @EnvironmentObject private var store: Store

    @ViewBuilder
    var body: some View {
        switch store.state.versionTwoOnboardingCompleted {
        case true:
            TabView {
                IntentionView()
                MeditationView()
                SetIntentionView()
            }
            .tabViewStyle(PageTabViewStyle())
        case false:
            OnboardingView()
        }
    }

}
