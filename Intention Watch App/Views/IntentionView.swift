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
            switch store.state.app {
                
            case let .mindfulState(mindfulTimeInterval):
                let progress = Converter.progress(mindfulTimeInterval: mindfulTimeInterval,
                                                  intentionTimeInterval: store.state.intention)
                let percentage = Converter.percentage(progress: progress)
                VStack {
                    IntentionProgressView(progress: progress,
                                          percentage: percentage)
                        .padding(.all, Style.spacing)
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
                
            default: // loading
                VStack {
                   IntentionProgressView(progress: 0,
                                         percentage: 0)
                        .padding(.all, Style.spacing)
                    Group {
                        ProgressLabel(timeInterval: 0,
                                      text: Texts.mindfulMinutes.localisation,
                                      accessibilityText: Texts.mindfulMinutes.localisation)
                        ProgressLabel(timeInterval: 0,
                                      text: Texts.intention.localisation,
                                      accessibilityText: Texts.intentionInMinutes.localisation)
                    }.accessibility(addTraits: .isHeader)
                }
            }
        }
        .onAppear() {
            Task {
                await store.dispatch(action: .fetchMindfulTimeInterval)
            }
        }
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
