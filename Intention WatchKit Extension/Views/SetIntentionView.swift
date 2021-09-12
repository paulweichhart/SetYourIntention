//
//  SetIntentionView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Foundation
import SwiftUI

struct SetIntentionView: View {
    
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: true) {
                VStack {
                    Group {
                        HStack {
                            Text(Texts.dailyIntention.localisation)
                                .font(.body)
                                .fontWeight(.light)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        HStack {
                            MinutesView(timeInterval: store.state.intention)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                    }.accessibility(addTraits: .isHeader)
                    HStack {
                        IntentionButton(action: .decrementIntention, systemName: "minus")
                            .accessibility(label: Text(Texts.decreaseIntention.localisation))
                        IntentionButton(action: .incrementIntention, systemName: "plus")
                            .accessibility(label: Text(Texts.increaseIntention.localisation))
                    }
                }
            }
        }
    }
}
    
struct MinutesView: View {
    
    let timeInterval: Double
    
    var body: some View {
        Group {
            Text("\(Converter.minutes(from: timeInterval))").font(.title2).fontWeight(.bold) + Text(" ") + Text(Texts.minutes.localisation).font(.title2).fontWeight(.light)
        }
        .accessibility(label: Text(Texts.intentionInMinutes.localisation))
        .accessibility(value: Text("\(Converter.minutes(from: timeInterval))"))

    }
}

struct IntentionButton: View {

    @EnvironmentObject var store: Store

    let action: Action
    let systemName: String
    
    var body: some View {
        Button(action: {
            Task {
                await store.dispatch(action: action)
            }
        }, label: {
            VStack {
                Image(systemName: systemName)
                    .font(.title2)
                    .foregroundColor(Colors.foreground.value)
                    .frame(height: 24)
                Text(Texts.minutes.localisation)
                    .fontWeight(.light)
                    .foregroundColor(.white)
            }
                .frame(maxWidth: .infinity, minHeight: 56, alignment: .center)
        })
    }
}

#if DEBUG
struct SetIntentionViewPreview: PreviewProvider {

    static var previews: some View {
        IntentionButton(action: .incrementIntention, systemName: "minus")
    }
}
#endif
