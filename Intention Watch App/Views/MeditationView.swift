//
//  PracticeView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 09.05.21.
//

import Foundation
import SwiftUI
import WatchKit

struct MeditationView: View {

    @EnvironmentObject private var store: Store

    @State private var isMeditating = false

    var body: some View {
         NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        Text(store.state.guided ? Texts.guided.localisation : Texts.unguided.localisation)
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
                        Task { @MainActor in
                            await Store.shared.dispatch(action: .startMeditating)
                            isMeditating.toggle()
                        }
                    }, label: {
                        Text(Texts.start.localisation)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: Layout.buttonBorderRadius.rawValue))
                }
            }
        }
        .sheet(isPresented: $isMeditating, content: {

            // Extract View https://www.swiftbysundell.com/articles/dismissing-swiftui-modal-and-detail-views/
            TabView {
                MeditationProgressView()
                    .toolbar(content: {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: {
                                
                            }, label: {
                                Text(Texts.done.localisation)
                            })
                            .foregroundColor(Colors.foreground.value)
                            .buttonStyle(.plain)
                        }
                    })
                NowPlayingView()
            }
            .tabViewStyle(.automatic)
            .onDisappear() {
                Task { @MainActor in
                    await store.dispatch(action: .stopMeditating)
                    await store.dispatch(action: .fetchMindfulTimeInterval)
                }
            }
        }).onChange(of: store.state.mindfulSessionState) {
            if case .initial = store.state.mindfulSessionState, isMeditating == true {
                isMeditating.toggle()
            }
        }
    }
}

struct MeditationProgressView: View {

    @ViewBuilder
    var body: some View {
        ZStack {
            switch Store.shared.state.mindfulSessionState {
            case .initial:
                Text(Texts.setYourIntention.localisation)

            case let .meditating(startDate):
                TimelineView(.periodic(from: startDate, by: 1.0)) { _ in
                    let progress = Date().timeIntervalSince(startDate) / Store.shared.state.intention
                    let percentage = Int(progress * 100)
                    MeditationProgressBar(progress: progress,
                                          percentage: percentage,
                                          timeInterval: Date().timeIntervalSince(startDate))
                }

            case let .error(error):
                ErrorView(error: error)
            }
        }
//        .animation(.easeInOut(duration: 1),
//                    value: store.state.mindfulSessionState)
    }
}

struct MeditationProgressBar: View {

    @EnvironmentObject private var store: Store

    let progress: Double
    let percentage: Int
    let timeInterval: TimeInterval

    var body: some View {
        ProgressBar(progress: progress,
                    percentage: percentage)
            .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
            .onChange(of: timeInterval) { _, _ in
                Task { @MainActor in
                    await store.dispatch(action: .tick)
                }
            }
    }
}

extension AppState {
    
    var isMeditating: Bool {
        switch mindfulSessionState {
        case .initial, .error:
            return false
        case .meditating:
            return true
        }
    }
}

#if DEBUG
struct PracticeViewPreview: PreviewProvider {

    static var previews: some View {
        MeditationView()
    }
}
#endif

