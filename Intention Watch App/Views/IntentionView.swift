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
            switch store.state.mindfulState {

            case .loading:
                VStack {
                    ProgressBar(progress: 0,
                                percentage: 0)
                    Group {
                        ProgressLabel(timeInterval: 0,
                                      text: Texts.mindfulMinutes.localisation,
                                      accessibilityText: Texts.mindfulMinutes.localisation)
                        ProgressLabel(timeInterval: 0,
                                      text: Texts.intention.localisation,
                                      accessibilityText: Texts.intentionInMinutes.localisation)
                    }.accessibility(addTraits: .isHeader)
                }

            case let .loaded(mindfulTimeInterval):
                let progress = Converter.progress(mindfulTimeInterval: mindfulTimeInterval,
                                                  intentionTimeInterval: store.state.intention)
                let percentage = Converter.percentage(progress: progress)
                VStack {
                    ProgressBar(progress: progress,
                                percentage: percentage)
                    Group {
                        ProgressLabel(timeInterval: mindfulTimeInterval,
                                      text: Texts.mindfulMinutes.localisation,
                                      accessibilityText: Texts.mindfulMinutes.localisation)
                        ProgressLabel(timeInterval: store.state.intention,
                                      text: Texts.intention.localisation,
                                      accessibilityText: Texts.intentionInMinutes.localisation)
                    }.accessibility(addTraits: .isHeader)
                }

            case let .error(error):
                ErrorView(error: error)
            }
        }.onAppear() {
            Task { @MainActor in
                await store.dispatch(action: .fetchMindfulTimeInterval)
            }
        }.onChange(of: scenePhase) { oldScenePhase, newScenePhase in
            if case .active = newScenePhase {
                Task { @MainActor in
                    await store.dispatch(action: .fetchMindfulTimeInterval)
                }
            }
        }
    }
}

struct ProgressBar: View {

    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    let progress: Double
    let percentage: Int

    private let lineWidth = 9.0
    private let degrees = 270.0

    private var strokeStyle: StrokeStyle {
        return StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round, miterLimit: 0, dash: [], dashPhase: 0)
    }

    private var visualProgress: CGFloat {
        guard progress > 0 else {
            return 0
        }
        return progress.truncatingRemainder(dividingBy: 1)
    }

    private var belowIntention: Bool {
        return progress < 1
    }

    private var foregroundColor: Color {
        return isLuminanceReduced ? Colors.dimmedForeground.value : Colors.foreground.value
    }

    private var rotation: Double {
        if progress <= 1 {
            return degrees
        }
        return degrees + (360 * visualProgress)
    }
    
    var body: some View {
        ZStack{
            // Background Color
            Circle()
                .strokeBorder(lineWidth: lineWidth)
                .foregroundColor(belowIntention ? Colors.background.value : foregroundColor)

            // Shadow
            Circle()
                .trim(from: visualProgress > 0 ? (visualProgress - 0.01) : 0,
                      to: progress > 0 ? (visualProgress + 0.01) : 0)
                .stroke(style: strokeStyle)
                .foregroundColor(Colors.shadow.value)
                .rotationEffect(Angle(degrees: degrees))
                .padding(lineWidth / 2)
                .blur(radius: 3)
            
            // Progress
            Circle()
                .trim(from: belowIntention ? 0 : 0.5,
                      to: belowIntention ? visualProgress : 1.0)
                .stroke(style: strokeStyle)
                .foregroundColor(foregroundColor)
                .rotationEffect(Angle(degrees: rotation))
                .padding(lineWidth / 2)
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

#if DEBUG
struct ProgressBarPreview: PreviewProvider {

    static var previews: some View {
        ProgressBar(progress: 1.0, percentage: 50)
            .environment(\.isLuminanceReduced, true)

        ProgressBar(progress: 0.5, percentage: 50)
            .environment(\.isLuminanceReduced, true)

        ProgressBar(progress: 2.0, percentage: 50)
            .environment(\.isLuminanceReduced, false)

        ProgressBar(progress: 1.0, percentage: 50)
            .environment(\.isLuminanceReduced, false)

        ProgressBar(progress: 0, percentage: 50)
            .environment(\.isLuminanceReduced, false)
    }
}
#endif
