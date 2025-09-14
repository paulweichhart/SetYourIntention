//
//  Extensions.swift
//  Intention
//
//  Created by Paul Weichhart on 04.07.25.
//

import SwiftUI

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
