//
//  Complication.swift
//  Complication
//
//  Created by Paul Weichhart on 08.09.22.
//

import WidgetKit
import SwiftUI

struct ComplicationProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> IntentionEntry {
        return placeholderEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (IntentionEntry) -> ()) {
        if context.isPreview {
            completion(placeholderEntry())
            return
        }
        Task { @MainActor in
            let entry = await intentionEntry()
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<Entry>) -> Void) {
        Task { @MainActor in
            let now = Date()
            let entry = await intentionEntry()
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(Converter.timeInterval(from: 15))
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    private func placeholderEntry() -> IntentionEntry {
        return IntentionEntry(date: Date(),
                              progress: 0.0,
                              intentionTimeInterval: Converter.timeInterval(from: 10),
                              mindfulTimeInterval: Converter.timeInterval(from: 0))
    }

    @MainActor
    private func intentionEntry() async -> IntentionEntry {
        let store = HealthStore()
        do {
            let mindfulTimeInterval = try await store.fetchMindfulTimeInterval()
            let intentionTimeInterval = UserDefaults(suiteName: Constants.appGroup.rawValue)?.double(forKey: Constants.intention.rawValue) ?? 0
            let progress = Converter.progress(mindfulTimeInterval: mindfulTimeInterval,
                                              intentionTimeInterval: intentionTimeInterval)
            return IntentionEntry(date: Date(),
                                  progress: min(progress, 1),
                                  intentionTimeInterval: intentionTimeInterval,
                                  mindfulTimeInterval: mindfulTimeInterval)
        } catch {
            return placeholderEntry()
        }
    }
}

struct IntentionEntry: TimelineEntry, Sendable {
    let date: Date

    let progress: Double
    let intentionTimeInterval: TimeInterval
    let mindfulTimeInterval: TimeInterval
}

struct ComplicationEntryView : View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.showsWidgetLabel) private var showsWidgetLabel
    @Environment(\.widgetRenderingMode) var renderingMode
    let entry: IntentionEntry

    private var mindful: Int {
        return Converter.minutes(from: entry.mindfulTimeInterval)
    }
    private var intention: Int {
        return Converter.minutes(from: entry.intentionTimeInterval)
    }

    @ViewBuilder
    var body: some View {
        switch family {
        case .accessoryCorner:
            ZStack {
                AccessoryWidgetBackground()
                switch renderingMode {
                case .fullColor:
                    Image("FullColor")
                        .resizable()
                        .mask(Circle())
                default:
                    Image("Accent")
                        .renderingMode(.template)
                        .resizable()
                }
            }.widgetLabel {
                ProgressView(value: entry.progress) {
                    Text("")
                }
                .progressViewStyle(.automatic)
                .tint(Colors.foreground.value)
            }.containerBackground(for: .widget) {
                Colors.foreground.value
            }
            .tint(Colors.foreground.value).progressViewStyle(.circular)

        case .accessoryInline:
            ViewThatFits {
                Text(Texts.mindful.localisation) + Text(" \(mindful)M • ") +  Text(Texts.intention.localisation) + Text(" \(intention)M")
            }
        case .accessoryCircular:
            ProgressView(value: entry.progress) {
                ZStack {
                    switch renderingMode {
                    case .fullColor:
                        Image("FullColor")
                            .resizable()
                            .mask(Circle())
                            .padding(.vertical, 7).padding(.horizontal, 7)
                    default:
                        Image("Accent")
                            .resizable()
                            .renderingMode(.template)
                            .mask(Circle())
                            .padding(.vertical, 7).padding(.horizontal, 7)
                    }
                }

            }.containerBackground(for: .widget) {
                Colors.foreground.value
            }
            .progressViewStyle(.circular).tint(Colors.foreground.value)
                .widgetLabel(label: { Text(Texts.mindful.localisation) + Text(" \(mindful)M • ") +  Text(Texts.intention.localisation) + Text(" \(intention)M")
                })

        case .accessoryRectangular:
            Text("")
        @unknown default:
            Text("")
        }
    }
}

@main
struct Complication: Widget {

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Constants.complication.rawValue,
                            provider: ComplicationProvider()) { entry in
            ComplicationEntryView(entry: entry)
        }
        .configurationDisplayName("Intention")
        .description("Intention Complication")
        .supportedFamilies([.accessoryCircular,
                            .accessoryCorner,
                            .accessoryInline])
    }
}

#if DEBUG
struct IntentionExtension_Previews: PreviewProvider {

    private static let intention = Converter.timeInterval(from: 10)
    private static let entry = IntentionEntry(date: Date(),
                                              progress: 0.7,
                                              intentionTimeInterval: Converter.timeInterval(from: 10),
                                              mindfulTimeInterval: Converter.timeInterval(from: 7))

    static var previews: some View {
        Group {
            ComplicationEntryView(entry: entry)
               .previewContext(WidgetPreviewContext(family: .accessoryCircular))
               .previewDisplayName("Circular")
            ComplicationEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryCorner))
                .previewDisplayName("Corner")
            ComplicationEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
                .previewDisplayName("Inline")
        }
    }
}
#endif
