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
            if isMeditating {
                Task {
                    await store.dispatch(action: .stopMeditating)
                    await store.dispatch(action: .fetchMindfulTimeInterval)
                }
            } else {
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
                Spacer()
                Button(action: {
                    isMeditating.toggle()
                }, label: {
                    Text(Texts.start.localisation)
                        .frame(maxWidth: .infinity, minHeight: 42, alignment: .center)
                        .foregroundColor(.black)
                        .background(Colors.foreground.value)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                })
                .buttonStyle(PlainButtonStyle())
            }
        }.background(.cyan)
        .sheet(isPresented: $isMeditating, content: {

            // Extract View https://www.swiftbysundell.com/articles/dismissing-swiftui-modal-and-detail-views/
            MeditationProgressView()
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
                Text("Set your Intention")

            case let .meditating(startDate):
                TimelineView(.periodic(from: startDate, by: 1)) { context in
                    ProgressBar(progress: store.state.mindfulSessionProgress ?? 0,
                                percentage: store.state.mindfulSessionPercentage ?? 0)
                }

            case let .error(error):
                ErrorView(error: error)
            }
        }.animation(.easeInOut(duration: 1),
                    value: store.state.mindfulSessionState)
    }
}

#if DEBUG
struct PracticeViewPreview: PreviewProvider {

    static var previews: some View {
        MeditationView()
    }
}
#endif

