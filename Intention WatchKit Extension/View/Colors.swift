//
//  Colors.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 25.10.20.
//

import Foundation
import SwiftUI

struct Colors {
    
    let foregroundColor = Color(.displayP3, red: 11/255, green: 223/255, blue: 224/255, opacity: 1)
    var backgroundColor: Color {
        return foregroundColor.opacity(0.2)
    }
    let shadowColor = Color(.displayP3, red: 0, green: 0, blue: 0, opacity: 0.9)
}
