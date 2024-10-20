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

    @WKApplicationDelegateAdaptor(ExtensionDelegate.self) var delegate

    var body: some Scene {

        WindowGroup {
            RootView()
                .environmentObject(Store.shared)
        }
    }
}

struct RootView: View {

    @EnvironmentObject private var store: Store

    @ViewBuilder
    var body: some View {
        switch store.state.versionAssistant.shouldShowOnboarding {
        case true:
            OnboardingView()
        case false:
            NavigationStack {
                TabView {
                    IntentionView()
                    MeditationView()
                    SetIntentionView()
                }
                .tabViewStyle(.verticalPage)
                .onAppear() {
                    Task { @MainActor in
                        await store.dispatch(action: .migrateToLatestVersion)
                        await store.dispatch(action: .fetchMindfulTimeInterval)
                    }
                }
            }
        }
    }

}
