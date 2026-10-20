//
//  StatisticsView.swift
//  Intention Watch App
//
//  Created by Paul Weichhart on 20.10.26.
//

import Charts
import Foundation
import SwiftUI

struct StatisticsView: View {

    @EnvironmentObject private var store: Store

    var body: some View {
        NavigationView {
            switch store.state.app {

            case let .mindfulState(mindfulState):
                MindfulStatisticsView(statistics: mindfulState.statistics,
                                      intention: store.state.intention)

            case let .error(error):
                ErrorView(error: error)

            default: // loading
                MindfulStatisticsView(statistics: [MindfulEntry(date: Date.now, timeInterval: 0)],
                                      intention: store.state.intention)
            }
        }
    }
}

struct MindfulStatisticsView: View {

    @Environment(\.isLuminanceReduced) var isLuminanceReduced

    let statistics: [MindfulEntry]
    let intention: TimeInterval

    var placeholder: [MindfulEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return (0..<statistics.count).reversed().compactMap { day in
            Calendar.current.date(byAdding: .day, value: -day, to: today).map { MindfulEntry(date: $0, timeInterval: 0) }
        }
    }

    private var foregroundColor: Color {
        return isLuminanceReduced ? Colors.dimmedForeground.value : Colors.foreground.value
    }

    var body: some View {
        VStack {
            Group {
                HStack {
                    Text(Texts.lastSevenDays.localisation)
                        .font(.body)
                        .fontWeight(.light)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                HStack {
                    Text(Texts.mindfulMinutes.localisation)
                        .font(.title2)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }.accessibility(addTraits: .isHeader)
            Chart {
                ForEach(statistics) { day in
                    BarMark(x: .value("Day", day.date, unit: .day),
                            y: .value("Minutes", Converter.minutes(from: day.timeInterval)))
                        .foregroundStyle(foregroundColor)
                        .cornerRadius(Style.size / 2)
                        .accessibilityLabel(Text(day.date, format: .dateTime.weekday(.wide)))
                        .accessibilityValue(Text("\(Converter.minutes(from: day.timeInterval))"))
                }
                if intention > 0 {
                    RuleMark(y: .value("Intention", Converter.minutes(from: intention)))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .accessibilityLabel(Text(Texts.intentionInMinutes.localisation))
                        .accessibilityValue(Text("\(Converter.minutes(from: intention))"))
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .padding(EdgeInsets(top: Style.spacing, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

#if DEBUG

#endif
