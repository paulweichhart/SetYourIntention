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
                    Button(action: {
                        intention.decrement()
                    }, label: {
                        Image(systemName: "minus")
                    }).foregroundColor(Colors().foregroundColor)
                
                    Button(action: {
                        intention.increment()
                    }, label: {
                        Image(systemName: "plus")
                    }).foregroundColor(Colors().foregroundColor)
                    
                }
                Spacer()
            }
        }
    }
}
