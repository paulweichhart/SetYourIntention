//
//  IntentionView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import Foundation
import SwiftUI

struct IntentionView: View {

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: Store
        
    var body: some View {
        NavigationView {
            switch store.state.mindfulTimeInterval {

            case let .success(mindfulTimeInterval):
                VStack {
                    ProgressBar(progress: store.state.progress,
                                percentage: store.state.percentage)
                    Group {
                        ProgressLabel(timeInterval: mindfulTimeInterval,
                                      text: Texts.mindfulMinutes.localisation,
                                      accessibilityText: Texts.mindfulMinutes.localisation)
                        ProgressLabel(timeInterval: store.state.intention,
                                      text: Texts.intention.localisation,
                                      accessibilityText: Texts.intentionInMinutes.localisation)
                    }.accessibility(addTraits: .isHeader)
                }

            case let .failure(error):
                ErrorView(error: error)
            }
        }.onAppear() {
            Task {
                await store.dispatch(action: .fetchMindfulTimeInterval)
            }
        }.onChange(of: scenePhase) { newScenePhase in
            if case .active = newScenePhase {
                Task {
                    await store.dispatch(action: .fetchMindfulTimeInterval)
                }
            }
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

    let timeInterval: TimeInterval
    let text: LocalizedStringKey
    let accessibilityText: LocalizedStringKey

    var body: some View {
        HStack() {
            Text(text)
                .fontWeight(.light)
                .font(.body) +
            Text(" ") +
            Text("\(Converter.minutes(from: timeInterval))")
                .fontWeight(.bold)
                .font(.body)
            Spacer()
        }
        .accessibility(label: Text(accessibilityText))
        .accessibility(value: Text("\(Converter.minutes(from: timeInterval))"))
    }
}