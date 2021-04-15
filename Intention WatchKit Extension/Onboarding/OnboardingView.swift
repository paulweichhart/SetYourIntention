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
        ScrollView {
            VStack(alignment: .leading) {
                Text(Texts.setYourIntention.localization)
                    .font(.headline)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                Text(Texts.welcome.localization)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
    }
}

struct InfoView: View {
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(Texts.info.localization)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
        }
    }
}

struct PermissionView: View {
    
    let intention: Intention
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(Texts.permission.localization)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                Button(action: {
                    Store.shared.permission(completion: { result in
                        if result {
                            DispatchQueue.main.async {
                                intention.onboardingCompleted = true
                            }
                        }
                    })
                }, label: {
                    Text(Texts.review.localization)
                        .font(.body)
                })
            }
        }
    }
}
