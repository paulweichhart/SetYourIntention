//
//  ErrorView.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 22.10.20.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    
    let error: StoreError
    
    var body: some View {
        
        switch error {
        case .permissionDenied, .noDataAvailable:
            VStack {
                Text("Please allow Intention to access your mindful Session in the Settings")
                Button("Open Settings", action: {
                    
                })
            }
        case .unavailable:
            Text("Sorry — your Device doesn't support Apple Health")
        }
    }
}
