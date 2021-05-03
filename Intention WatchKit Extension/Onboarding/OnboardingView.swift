//
//  OnboardingView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 23.11.20.
//

import Combine
import Foundation
import SwiftUI
import WatchKit

struct OnboardingView: View {
    
    let intention: Intention
    
    var body: some View {
        TabView {
            WelcomeView()
            InfoView()
            PermissionView(viewModel: PermissionViewModel(intention: intention))
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
    
    @ObservedObject private var viewModel: PermissionViewModel

    init(viewModel: PermissionViewModel) {
        self.viewModel = viewModel
    }

    private var cancellable = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(Texts.permission.localisation)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    Button(action: {
                        viewModel.initialiseStore()
                    }, label: {
                        Text(Texts.review.localisation)
                            .font(.body)
                    })
                }
            }
        }
    }
}
