//
//  EditIntentionView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 19.10.20.
//

import Foundation
import SwiftUI

struct EditIntentionView: View {
    
    @EnvironmentObject var intention: Intention
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Your Daily Intention")
                        .font(.system(size: 16))
                        .fontWeight(.light)
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 0, bottom: -8, trailing: 0))
                HStack {
                    Text("\(Int(intention.mindfulMinutes))")
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                    Text("Minutes")
                        .font(.system(size: 32))
                        .fontWeight(.light)
                    Spacer()
                }
                HStack {
                    IntentionButton(systemName: "minus", action: intention.decrement)
                    IntentionButton(systemName: "plus", action: intention.increment)
                }
                Spacer()
            }
        }
    }
}

struct IntentionButton: View {
    
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        GeometryReader { reader in
            Button(action: {
                action()
            }, label: {
                Image(systemName: systemName)
                    .font(.system(size: 32))
                    .foregroundColor(Colors().foregroundColor)
                    .background(Color.clear)
                    .frame(width: reader.size.width, height: reader.size.width, alignment: .center)
                    .contentShape(Rectangle())
            })
            .buttonStyle(PlainButtonStyle())
        }
    }
}
