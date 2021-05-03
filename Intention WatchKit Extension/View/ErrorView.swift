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
        case .permissionDenied:
            Text(Texts.ctaOpenSettings.localisation)

        case .unavailable:
            Text(Texts.unavailable.localisation)

        case .noDataAvailable:
            Text(Texts.noDataAvailable.localisation)
        }
    }
}
