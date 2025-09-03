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

    var body: some View {
        TabView {
            WelcomeView()
            InfoView()
            PermissionView()
        }
        .tabViewStyle(PageTabViewStyle())
    }
}

struct WelcomeView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(Texts.setYourIntention.localisation)
                        .font(.headline)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(Texts.welcome.localisation)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }
        }
    }
}

struct InfoView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(Texts.info.localisation)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()

                }
            }
        }
    }
}

struct PermissionView: View {
    
    @EnvironmentObject private var store: Store

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(Texts.permission.localisation)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                    Button(action: {
                        Task {
                            await store.dispatch(action: .requestHealthStorePermission)
                            await store.dispatch(action: .setup)
                        }
                    }, label: {
                        Text(Texts.review.localisation)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: Layout.buttonBorderRadius.rawValue))
                    .apply {
                        if #available(watchOS 26.0, *) {
                            $0.buttonStyle(.glass)
                        }
                    }
                }
            }
        }
    }
}
