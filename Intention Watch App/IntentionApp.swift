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
    
    private let store = Store.shared

    var body: some Scene {

        WindowGroup {
            RootView()
                .environmentObject(store)
                .onAppear() {
                       Task { @MainActor in
                            await store.dispatch(action: .setupInitialState)
                        }
                    }
        }
    }
}

struct RootView: View {
    
    @EnvironmentObject private var store: Store
    
    @ViewBuilder
    var body: some View {
        switch store.state.navigationState {
        case .loading:
            ZStack {
                Image("Loading")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
                VStack {
                    Spacer()
                    Text(Texts.setYourIntention.localisation)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
        case .presentOnboarding:
            OnboardingView()
        default:
            IntentionAppView()
        }
    }
}
    
struct IntentionAppView: View {
    
    @EnvironmentObject private var store: Store
 
    var body: some View {
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
