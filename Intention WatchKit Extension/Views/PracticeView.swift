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
    @State private var isMeditating = false {
        didSet {
            print("isMeditating: \(isMeditating)")
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
            let startDate = Date()
            TimelineView(.periodic(from: startDate, by: 1)) { context in
                let timeInterval = Date().timeIntervalSince(startDate)
                let progress = timeInterval / store.state.intention
                ProgressBar(progress: progress, percentage: 50)
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
                })
            })
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

