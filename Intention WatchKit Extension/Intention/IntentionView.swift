//
//  IntentionView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import Foundation
import SwiftUI
import WatchKit

struct IntentionView: View {
    
    @ObservedObject private var viewModel: IntentionViewModel
    @EnvironmentObject var intention: Intention
        
    init(viewModel: IntentionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Circle()
                    .strokeBorder(lineWidth: 8)
                    .foregroundColor(.yellow)
                    .padding(4)
                Text("\(intention.minutes)")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
            }
            .navigationTitle("Intention")
        }.onAppear {
            print("refreshMe")
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.red)
        }
    }
}
