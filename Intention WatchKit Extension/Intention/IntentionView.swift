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
        }
    }
}

struct ProgressBar: View {
    
    let mindfulMinutes: Double
    let intention: Double
    
    private let lineWidth: CGFloat = 12.0
    private var belowIntention: Bool {
        return (mindfulMinutes / intention) < 1
    }
    
    private var progress: CGFloat {
        let progress = CGFloat(mindfulMinutes / intention)
        if belowIntention {
            return progress
        }
        let remainder = progress.truncatingRemainder(dividingBy: 1)
        return remainder == 0 ? 0.99 : remainder
    }
    
    var body: some View {
        VStack {
            ZStack{
                Circle()
                    .strokeBorder(lineWidth: lineWidth)
                    .foregroundColor(belowIntention ? Colors().backgroundColor : Colors().foregroundColor)
                if !belowIntention {
                    Circle()
                        .trim(from: progress - 0.01, to: progress + 0.01)
                        .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                        .foregroundColor(Colors().backgroundColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .padding(lineWidth/2)
                        .animation(.easeInOut)
                        .blur(radius: 3)
                }
                Circle()
                    .trim(from: belowIntention ? 0 : (progress - 0.1), to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                    .foregroundColor(Colors().foregroundColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .padding(lineWidth/2)
                    .animation(.easeInOut)
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            HStack() {
                Text("Intention")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                Text("\(Int(intention))")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                Spacer()
            }
            HStack() {
                Text("Mindful Minutes")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                Text("\(Int(mindfulMinutes))")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
}
