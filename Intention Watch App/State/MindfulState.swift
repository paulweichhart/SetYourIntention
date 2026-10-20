//
//  MindfulState.swift
//  Intention Watch App
//
//  Created by Paul Weichhart on 20.10.26.
//

import Foundation

struct MindfulEntry: Equatable, Identifiable {

    let date: Date
    let timeInterval: TimeInterval

    var id: Date {
        return date
    }
}

struct MindfulState: Equatable {

    let timeInterval: TimeInterval
    let statistics: [MindfulEntry]
}
