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
                    .foregroundColor(.yellow)
                HStack {
                    Button("-", action: {
                        intention.decrement()
                    })
                
                    Button("+", action: {
                        intention.increment()
                    })
                }
            }
            .navigationTitle("Intention")
        }
    }
}
