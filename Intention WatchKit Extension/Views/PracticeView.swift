//
//  PracticeView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 09.05.21.
//

import Foundation
import SwiftUI

struct PracticeView: View {

    @EnvironmentObject private var store: Store
    @State private var isMeditating = false

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
                Button(Texts.start.localisation, action: {
                    Task {
                        await store.dispatch(action: .startMeditating)
                        isMeditating.toggle()
                    }
                })
                .foregroundColor(.black)
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, minHeight: 42, alignment: .center)
                .background(Colors.foreground.value)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .sheet(isPresented: $isMeditating, content: {

            // Extract View https://www.swiftbysundell.com/articles/dismissing-swiftui-modal-and-detail-views/
            if case let .meditating(startDate) = store.state.mindfulSessionState {
                TimelineView(.periodic(from: startDate, by: 1)) { context in
                    VStack {
                        Spacer()
                        ProgressBar(progress: store.state.mindfulSessionProgress ?? 0,
                                    percentage: store.state.mindfulSessionPercentage ?? 0)
                        Spacer()
                    }
                }
                .toolbar(content: {
                    ToolbarItem(placement: .cancellationAction, content: {
                        Button(Texts.done.localisation, action: {
                            Task {
                                await store.dispatch(action: .stopMeditating)
                                await store.dispatch(action: .fetchMindfulTimeInterval)
                                isMeditating.toggle()
                            }
                        })
                            .foregroundColor(Colors.foreground.value)
                    })
                })
            }
        })
    }
}

#if DEBUG
struct PracticeViewPreview: PreviewProvider {

    static var previews: some View {
        PracticeView()
    }
}
#endif

