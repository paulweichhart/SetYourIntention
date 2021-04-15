//
//  SetIntentionView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Foundation
import SwiftUI

struct SetIntentionView: View {
    
    @ObservedObject private var intention: Intention

    init(intention: Intention) {
        self.intention = intention
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: true) {
                VStack {
                    Group {
                        HStack {
                            Text(Texts.dailyIntention.localization)
                                .font(.body)
                                .fontWeight(.light)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        HStack {
                            MinutesView(minutes: intention.minutes)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                    }.accessibility(addTraits: .isHeader)
                    HStack {
                        IntentionButton(systemName: "minus", action: intention.decrement)
                            .accessibility(label: Text(Texts.decreaseIntention.localization))
                        IntentionButton(systemName: "plus", action: intention.increment)
                            .accessibility(label: Text(Texts.increaseIntention.localization))
                    }
                }
            }
        }
    }
}
    
struct MinutesView: View {
    
    let minutes: Double
    
    var body: some View {
        Group {
            Text("\(Int(minutes))").font(.title2).fontWeight(.bold) + Text(" ") + Text(Texts.minutes.localization).font(.title2).fontWeight(.light)
        }
        .accessibility(label: Text(Texts.intentionInMinutes.localization))
        .accessibility(value: Text("\(Int(minutes))"))

    }
}

struct IntentionButton: View {
    
    let systemName: String
    let action: (() -> Void)
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            Image(systemName: systemName)
                .font(.largeTitle)
                .frame(maxWidth: .infinity, minHeight: 75, alignment: .center)
                .contentShape(Rectangle())
        })
        .foregroundColor(Colors.foreground.value)
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct SetIntentionViewPreview: PreviewProvider {

    static var previews: some View {
        SetIntentionView(intention: Intention())
    }
}
#endif
