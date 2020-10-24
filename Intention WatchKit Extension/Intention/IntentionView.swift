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
                switch viewModel.state {
                
                case .loading:
                    Text("Loading Data")
                    
                case let .mindfulMinutes(mindfulMinutes):
                    ProgressBar(mindfulMinutes: mindfulMinutes, intention: intention.mindfulMinutes)
                
                case let .error(error):
                    ErrorView(error: error)
                }
            }
            .navigationTitle("Intention")
        }
    }
}

struct ProgressBar: View {
    
    let mindfulMinutes: Double
    let intention: Double
    
    private let lineWidth: CGFloat = 12.0
    private var progress: CGFloat {
        return CGFloat(mindfulMinutes / intention)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: lineWidth)
                .foregroundColor(.yellow)
                .opacity(0.3)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                .foregroundColor(.yellow)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(lineWidth/2)
                .animation(.easeInOut)
            Text("\(Int(mindfulMinutes))")
                .font(.largeTitle)
                .foregroundColor(.yellow)
                .animation(.default)
        }
    }
}
