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
                Text("\(Int(intention.mindfulMinutes))")
                    .font(.largeTitle)
                    .foregroundColor(Colors().foregroundColor)
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
            }
            .navigationTitle("Intention")
        }
    }
}
