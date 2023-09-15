//
//  SetIntentionView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Foundation
import SwiftUI

struct SetIntentionView: View {
    
    @EnvironmentObject private var store: Store
    @State private var guided = Store.shared.state.guided

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
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                    }.accessibility(addTraits: .isHeader)
                    HStack {
                        IntentionButton(action: .decrementIntention, systemName: Icons.minus.rawValue)
                            .accessibility(label: Text(Texts.decreaseIntention.localisation))
                        IntentionButton(action: .incrementIntention, systemName: Icons.plus.rawValue)
                            .accessibility(label: Text(Texts.increaseIntention.localisation))
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))

                    Button(action: {
                        guided.toggle()
                    }, label: {
                        Toggle(isOn: $guided, label: {
                            Text(Texts.guidedMeditation.localisation)
                                .font(.body)
                                .fontWeight(.light)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        })
                        .tint(Colors.foreground.value)
                        .onChange(of: guided) { oldValue, newValue in
                            Task {
                                await store.dispatch(action: .guided(newValue))
                            }
                        }
                    })
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                    .buttonBorderShape(.roundedRectangle(radius: Layout.buttonBorderRadius.rawValue))
                    Text(Texts.guidedInfoText.localisation)
                        .font(.footnote)
                        .fontWeight(.light)
                        .opacity(0.7)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 0))
                }
            }
        }
    }
}
    
struct MinutesView: View {
    
    let timeInterval: Double

    private var minutesLocalisation: LocalizedStringKey {
        return timeInterval == Converter.timeInterval(from: 1) ? Texts.minute.localisation : Texts.minutes.localisation
    }
    
    var body: some View {
        Group {
            Text("\(Converter.minutes(from: timeInterval))").font(.title2).fontWeight(.bold) + Text(" ") + Text(minutesLocalisation).font(.title2).fontWeight(.light)
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
        .buttonBorderShape(.roundedRectangle(radius: Layout.buttonBorderRadius.rawValue))
    }
}

#if DEBUG
struct SetIntentionViewPreview: PreviewProvider {

    static var previews: some View {
        IntentionButton(action: .incrementIntention, 
                        systemName: "minus")
    }
}
#endif
