//
//  Colors.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 25.10.20.
//

import SwiftUI

enum Colors {

    case background
    case foreground
    case dimmedForeground
    case shadow
    
    var value: Color {
        switch self {
        case .background:
            return Color(.displayP3, red: 25/255, green: 25/255, blue: 25/255, opacity: 1)
        case .foreground:
            return Color(.displayP3, red: 94/255, green: 204/255, blue: 204/255, opacity: 1)
        case .shadow:
            return Color(.displayP3, red: 0, green: 0, blue: 0, opacity: 0.6)
        case .dimmedForeground:
            return Color(.displayP3, red: 80/255, green: 121/255, blue: 121/255, opacity: 1)
        }
    }
}
