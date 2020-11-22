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
                    ProgressBar(mindfulMinutes: 0, intention: intention.mindfulMinutes)
                    
                case let .mindfulMinutes(mindfulMinutes):
                    ProgressBar(mindfulMinutes: mindfulMinutes, intention: intention.mindfulMinutes)
                
                case let .error(error):
                    ErrorView(error: error)
                }
            }
        }.onAppear() {
            viewModel.mindfulMinutes()
        }
    }
}

struct ProgressBar: View {
    
    let mindfulMinutes: Double
    let intention: Double
    
    private let lineWidth: CGFloat = 9.0
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
                Circle()
                    .trim(from: progress > 0 ? (progress - 0.01) : 0, to: progress > 0 ? (progress + 0.01) : 0)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                    .foregroundColor(Colors().shadowColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .padding(lineWidth/2)
                    .blur(radius: 3)
                Circle()
                    .trim(from: belowIntention ? 0 : (progress - 0.1), to: progress)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0))
                    .foregroundColor(Colors().foregroundColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .padding(lineWidth/2)
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            HStack() {
                Text("Mindful Minutes")
                    .font(.system(size: 15))
                    .fontWeight(.light)
                Text("\(Int(mindfulMinutes))")
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                Spacer()
            }
            HStack() {
                Text("Intention")
                    .font(.system(size: 15))
                    .fontWeight(.light)
                Text("\(Int(intention))")
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                Spacer()
            }
        }
    }
}
