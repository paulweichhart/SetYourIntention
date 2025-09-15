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
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: Style.size * 2, trailing: 0))
                    Button(action: {
                        Task {
                            await Store.shared.dispatch(action: .startMeditating)
                        }
                    }, label: {
                        Text(Texts.start.localisation)
                    })
                    .buttonBorderShape(.roundedRectangle(radius: Layout.buttonBorderRadius.rawValue))
                    .apply {
                        if #available(watchOS 26.0, *) {
                            $0.buttonStyle(.glass)
                        } else {
                            $0
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isMeditating, content: {

            // Extract View https://www.swiftbysundell.com/articles/dismissing-swiftui-modal-and-detail-views/
            TabView {
                MeditationProgressView()
                    .toolbar(content: {
                        ToolbarItem(placement: .primaryAction) {
                        }
                    })
                NowPlayingView()
            }
            .tabViewStyle(.automatic)
            .onDisappear() {
                Task {
                    await store.dispatch(action: .stopMeditatingAndFetchMindfulTimeInterval)
                }
            }
        }).onChange(of: store.state.app) {
            switch store.state.app {
            case .meditating:
                isMeditating = true
            default:
                isMeditating = false
            }
        }
    }
}

struct MeditationProgressView: View {
    
    @EnvironmentObject private var store: Store

    var body: some View {
        ZStack {
            if case let .meditating(startDate) = store.state.app {
                TimelineView(.periodic(from: startDate, by: 1)) { _ in
                    let timeInterval = floor(Date().timeIntervalSince(startDate))
                    let progress = Date().timeIntervalSince(startDate) / store.state.intention
                    let percentage = Int(progress * 100)
                    withAnimation {
                        IntentionProgressView(progress: progress,
                                              percentage: percentage)
                        .padding(EdgeInsets(top: Style.size, leading: 0, bottom: 0, trailing: 0))
                    }
                    .onChange(of: timeInterval) { _, _ in
                        if timeInterval.truncatingRemainder(dividingBy: Converter.timeInterval(from: 1)) == 0 {
                            Task {
                                await store.dispatch(action: .tick)
                            }
                        }
                    }
                }
            }
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

