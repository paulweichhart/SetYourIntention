//
//  IntentionView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import Foundation
import SwiftUI
import WatchKit

struct IntentionView: View {
    
    private let viewModel: IntentionViewModel
        
    init(viewModel: IntentionViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Circle()
                    .strokeBorder(lineWidth: 7)
                    .foregroundColor(.yellow)
                Text("\(viewModel.mindfulMinutes)")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
            }
            .navigationTitle("Intention")
        }
    }
}

struct EditView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                Text("20")
                    .font(.largeTitle)
                    .foregroundColor(.yellow)
                HStack {
                    Button("-", action: {
    //                    viewModel.intendedMinutes -= 5
                    })
                
                    Button("+", action: {
    //                    viewModel.intendedMinutes += 5
                    })
                }
            }
        }
    }
}
