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

    var body: some View {
        switch store.state.versionTwoOnboardingCompleted {
        case true:
            TabView {
                IntentionView()
                PracticeView()
                SetIntentionView()
            }
            .tabViewStyle(PageTabViewStyle())
        case false:
            OnboardingView()
        }
    }

}
