//
//  ComplicationController.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import ClockKit
import Foundation

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
         let descriptors = [
             CLKComplicationDescriptor(identifier: "complication",
                                       displayName: "Intention",
                                       supportedFamilies: [.circularSmall, .graphicCircular])
         ]
         handler(descriptors)
     }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        case .circularSmall, .graphicCircular:
            
            switch Store.shared.state {
            case .error, .initial, .available:
                handler(createTimelineEntry(mindfulMinutes: 0))
            case let .mindfulMinutes(minutes):
                handler(createTimelineEntry(mindfulMinutes: minutes))
            }
        default:
            handler(nil)
        }
    }
    
    private func createTimelineEntry(mindfulMinutes: Double) -> CLKComplicationTimelineEntry {
        let fraction = min(Float(mindfulMinutes / Intention().minutes), 1)
        let provider = CLKSimpleGaugeProvider(style: .fill,
                                              gaugeColor: UIColor(Colors().foregroundColor),
                                              fillFraction: fraction)
        let activeMinutes = CLKSimpleTextProvider(text: "\(Int(mindfulMinutes))")
        let template = CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: provider,
                                                                             centerTextProvider: activeMinutes)
        return CLKComplicationTimelineEntry(date: Date(),
                                            complicationTemplate: template)
    }
}
