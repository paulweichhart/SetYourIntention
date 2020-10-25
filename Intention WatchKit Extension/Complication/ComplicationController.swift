//
//  ComplicationController.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import ClockKit


final class ComplicationController: NSObject, CLKComplicationDataSource {
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        case .circularSmall, .graphicCircular:
            
            let intention = Intention()
            let mindfulMinutes: Double
            switch Store.shared.state {
            case .available, .initial, .error:
                mindfulMinutes = 0
            case let .mindfulMinutes(minutes):
                mindfulMinutes = minutes
            }
            let provider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .yellow, fillFraction: Float(mindfulMinutes / intention.mindfulMinutes))
            let activeMinutes = CLKSimpleTextProvider(text: "\(Int(mindfulMinutes))")
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: provider, centerTextProvider: activeMinutes)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        default:
            handler(nil)
        }
    }
}
