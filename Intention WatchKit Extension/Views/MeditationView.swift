//
//  PracticeView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 09.05.21.
//

import Foundation
import SwiftUI

struct MeditationView: View {

    @EnvironmentObject private var store: Store
    @State private var isMeditating = false {
        willSet {
            if !isMeditating {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    Task {
                        await store.dispatch(action: .startMeditating)
                    }
                })
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text(Texts.unguided.localisation)
                            .font(.body)
                            .fontWeight(.light)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    HStack {
                        Text(Texts.meditation.localisation)
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                    Button(action: {
                        isMeditating.toggle()
                    }, label: {
                        Text(Texts.start.localisation)
                    })
                }
            }
        }
        .sheet(isPresented: $isMeditating, content: {

            // Extract View https://www.swiftbysundell.com/articles/dismissing-swiftui-modal-and-detail-views/

            MeditationProgressView()
                .onDisappear(perform: {
                    Task {
                        await store.dispatch(action: .stopMeditating)
                        await store.dispatch(action: .fetchMindfulTimeInterval)
                    }
                })
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction, content: {
                        Button(Texts.done.localisation, action: {
                            isMeditating.toggle()
                        })
                        .foregroundColor(Colors.foreground.value)
                    })
                })
        })
    }
}

struct MeditationProgressView: View {

    @EnvironmentObject private var store: Store

    @ViewBuilder
    var body: some View {
        ZStack {
            switch store.state.mindfulSessionState {
            case .initial:
                Text(Texts.setYourIntention.localisation)

            case let .meditating(startDate):
                TimelineView(.periodic(from: startDate, by: 1.0)) { _ in
                    let progress = Date().timeIntervalSince(startDate) / store.state.intention
                    let percentage = Int(progress * 100)
                    ProgressBar(progress: progress,
                                percentage: percentage)
                        .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
                }

            case let .error(error):
                ErrorView(error: error)
            }
        }.animation(.easeInOut(duration: 1),
                    value: store.state.mindfulSessionState)
    }
}

struct ProgressTimelineSchedule: TimelineSchedule {
    var startDate: Date

    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(from: startDate, by: 1.0).entries(from: startDate, mode: mode)
    }
}

#if DEBUG
struct PracticeViewPreview: PreviewProvider {

    static var previews: some View {
        MeditationView()
    }
}
#endif

