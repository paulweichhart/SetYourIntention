//
//  ComplicationController.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import ClockKit


final class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Intention", supportedFamilies: [.circularSmall, .graphicCircular])
        ]
        handler(descriptors)
    }
    
//    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
//        // Do any necessary work to support these newly shared complication descriptors
//    }

    // MARK: - Timeline Configuration
    
//    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
//        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
//        handler(Date().addingTimeInterval(24.0 * 60.0 * 60.0))
//    }
//
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.hideOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        case .circularSmall, .graphicCircular:
            
            let minutes: Double
            switch Store.shared.state {
            case .available, .initial, .error:
                minutes = 0
            case let .mindfulMinutes(mindfulMinutes):
                minutes = mindfulMinutes
            }
            let provider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: Float(minutes / UserDefaults.standard.double(forKey: "intention")))
            let activeMinutes = CLKSimpleTextProvider(text: "\(Int(minutes))")
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: provider, centerTextProvider: activeMinutes)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        default:
            handler(nil)
        }
    }
    
//    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
//        // Call the handler with the timeline entries after the given date
//        let fiveMinutes = 5.0 * 60.0
//        let twentyFourHours = 24.0 * 60.0 * 60.0
//
//        // Create an array to hold the timeline entries.
//        var entries = [CLKComplicationTimelineEntry]()
//
//        // Calculate the start and end dates.
//        var current = date.addingTimeInterval(fiveMinutes)
//        let endDate = date.addingTimeInterval(twentyFourHours)
//
//        // Create a timeline entry for every five minutes from the starting time.
//        // Stop once you reach the limit or the end date.
//        while (current.compare(endDate) == .orderedAscending) && (entries.count < limit) {
//            entries.append(createTimelineEntry(forComplication: complication, date: current))
//            current = current.addingTimeInterval(fiveMinutes)
//        }
//
//        handler(entries)
//    }
//
//    // MARK: - Sample Templates
//
//    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
//        // This method will be called once per supported complication, and the results will be cached
//        handler(nil)
//    }
//
//    private func createTimelineEntry(forComplication complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry {
//        let template = createGraphicCircleTemplate(forDate: date)
//
//        // Use the template and date to create a timeline entry.
//        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
//    }
//
//    private func createGraphicCircleTemplate(forDate date: Date) -> CLKComplicationTemplate {
//        // Create the data providers.
//        let minutes: Double
//        switch Store.shared.state {
//        case .available, .initial, .error:
//            minutes = 0
//        case let .mindfulMinutes(mindfulMinutes):
//            minutes = mindfulMinutes
//        }
//
//
//        let activeMinutes = CLKSimpleTextProvider(text: "\(Int(minutes))")
//        return CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: provider, centerTextProvider: activeMinutes)
//    }
}
