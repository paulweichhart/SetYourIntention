//
//  StatsView.swift
//  Intention Watch App
//
//  Created by Paul Weichhart on 08.08.26.
//

import Charts
import Foundation
import SwiftUI

struct StatsView: View {

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: Store

    var body: some View {
        VStack(alignment: .leading, spacing: Style.spacing) {
            Text(Texts.mindfulMinutes.localisation)
                .font(.headline)
                .foregroundStyle(Colors.foreground.value)
            Chart(store.state.weeklyMindfulData) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Minutes", item.minutes)
                )
                .foregroundStyle(Colors.foreground.value)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing)
            }
        }
        .task {
            await store.dispatch(action: .fetchWeeklyMindfulData)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Task {
                    await store.dispatch(action: .fetchWeeklyMindfulData)
                }
            }
        }
    }
}
