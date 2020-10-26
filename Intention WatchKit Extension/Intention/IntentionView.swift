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
                    ProgressBar(mindfulMinutes: 10, intention: intention.mindfulMinutes)
                
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
    
    private var beyondIntention: Bool {
        return (mindfulMinutes / intention) > 1
    }
    
    private var progress: CGFloat {
        let progress = CGFloat(mindfulMinutes / intention)
        return beyondIntention ? progress.truncatingRemainder(dividingBy: 1) : progress
    }
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(lineWidth: lineWidth)
                .foregroundColor(beyondIntention ? Colors().foregroundColor : Colors().backgroundColor)
            Circle()
                .trim(from: progress - 0.01, to: progress + 0.01)
                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                .foregroundColor(Colors().backgroundColor)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(lineWidth/2)
                .animation(.easeInOut)
                .blur(radius: 3)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                .foregroundColor(Colors().foregroundColor)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(lineWidth/2)
                .animation(.easeInOut)
            Text("\(Int(mindfulMinutes))")
                .font(.system(size: 64))
                .foregroundColor(Colors().foregroundColor)
        }
    }
}
