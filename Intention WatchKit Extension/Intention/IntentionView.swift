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
        
    init(viewModel: IntentionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            switch viewModel.state {
            
            case .loading:
                VStack {
                    ProgressBar(progress: 0, percentage: 0)
                    Group {
                        ProgressLabel(minutes: 0,
                                      text: Texts.mindfulMinutes.localisation,
                                      accessibilityText: Texts.mindfulMinutes.localisation)
                        ProgressLabel(minutes: 0,
                                      text: Texts.intention.localisation,
                                      accessibilityText: Texts.intentionInMinutes.localisation)
                    }.accessibility(addTraits: .isHeader)
                }
                
            case let .minutes(minutes):
                VStack {
                    ProgressBar(progress: minutes.progress,
                                percentage: minutes.percentage)
                    Group {
                        ProgressLabel(minutes: minutes.mindful,
                                      text: Texts.mindfulMinutes.localisation,
                                      accessibilityText: Texts.mindfulMinutes.localisation)
                        ProgressLabel(minutes: minutes.intention,
                                      text: Texts.intention.localisation,
                                      accessibilityText: Texts.intentionInMinutes.localisation)
                    }.accessibility(addTraits: .isHeader)
                }
            
            case let .error(error):
                ErrorView(error: error)
            }
        }.onAppear() {
            viewModel.mindfulMinutes()
        }
    }
}

struct ProgressBar: View {

    let progress: Double
    let percentage: Int

    private let lineWidth: CGFloat = 9.0

    private var strokeStyle: StrokeStyle {
        return StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)
    }

    private var visualProgress: CGFloat {
        guard progress > 0 else {
            return 0
        }

        let remainder = progress.truncatingRemainder(dividingBy: 1)
        let progress = remainder == 0 ? 0.99 : remainder
        return CGFloat(progress)
    }

    private var belowIntention: Bool {
        return progress < 1
    }
    
    var body: some View {
        ZStack{
            // Background Color
            Circle()
                .strokeBorder(lineWidth: lineWidth)
                .foregroundColor(belowIntention ? Colors.background.value : Colors.foreground.value)

            // Shadow
            Circle()
                .trim(from: visualProgress > 0 ? (visualProgress - 0.01) : 0,
                      to: visualProgress > 0 ? (visualProgress + 0.01) : 0)
                .stroke(style: strokeStyle)
                .foregroundColor(Colors.shadow.value)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(lineWidth/2)
                .blur(radius: 3)
            
            // Progress
            Circle()
                .trim(from: belowIntention ? 0 : (visualProgress - 0.1),
                      to: visualProgress)
                .stroke(style: strokeStyle)
                .foregroundColor(Colors.foreground.value)
                .rotationEffect(Angle(degrees: 270.0))
                .padding(lineWidth/2)
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
        .accessibility(label: Text(Texts.progressInMinutes.localisation))
        .accessibility(value: Text("\(percentage)"))
        .accessibility(addTraits: .isHeader)
    }
}

struct ProgressLabel: View {

    let minutes: Double
    let text: LocalizedStringKey
    let accessibilityText: LocalizedStringKey

    var body: some View {
        HStack() {
            Text(text)
                .fontWeight(.light)
                .font(.body) +
            Text(" ") +
            Text("\(Int(minutes))")
                .fontWeight(.bold)
                .font(.body)
            Spacer()
        }
        .accessibility(label: Text(accessibilityText))
        .accessibility(value: Text("\(Int(minutes))"))
    }
}
