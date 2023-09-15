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
        switch Store.shared.state.versionAssistant.shouldShowOnboarding {
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
                    Task {
                        await store.dispatch(action: .migrateToLatestVersion)
                    }
                }
                /*
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            // NavigationLink("Settings", value: 2)
                        } label: {
                            Image(systemName: Icons.stats.rawValue)
                        }
                    }
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            // NavigationLink("Settings", value: 2)
                        } label: {
                            Image(systemName: Icons.leaf.rawValue)
                        }
                        
                        Button {
                            // NavigationLink("Settings", value: 2)
                        } label: {
                            Image(systemName: Icons.gear.rawValue)
                        }
                    }
                }
                 */
            }
        }
    }

}
