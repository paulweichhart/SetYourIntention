//
//  OnboardingView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 23.11.20.
//

import Foundation
import SwiftUI
import WatchKit

struct OnboardingView: View {
    
    let intention: Intention
    
    var body: some View {
        TabView {
            WelcomeView()
            InfoView()
            PermissionView(intention: intention)
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct WelcomeView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Set Your Intention")
                .font(.system(size: 15))
                .fontWeight(.bold)
            Text("Use your preferred Meditation App with support for Apple Health and keep track of your Mindful Minutes")
            Spacer()
        }.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
    }
}

struct InfoView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Mind your mental well being with the supported Complication on your  Watch")
            Spacer()
        }
    }
}

struct PermissionView: View {
    
    let intention: Intention
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please allow the App to access your Mindful Minutes from Apple Health")
            Spacer()
            Button(action: {
                Store.shared.permission(completion: { result in
                    if result {
                        DispatchQueue.main.async {
                            intention.onboardingCompleted = true
                        }
                    }
                })
            }, label: {
                Text("Review")
            }).padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
        }
    }
}
