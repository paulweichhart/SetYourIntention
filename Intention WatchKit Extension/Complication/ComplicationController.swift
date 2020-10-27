//
//  ComplicationController.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import ClockKit

final class ComplicationController: NSObject, CLKComplicationDataSource {
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
         let descriptors = [
             CLKComplicationDescriptor(identifier: "complication", displayName: "Intention", supportedFamilies: [.circularSmall, .graphicCircular])
         ]
         handler(descriptors)
     }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        switch complication.family {
        case .circularSmall, .graphicCircular:
            
            let mindfulMinutes: Double
            switch Store.shared.state {
            case .available, .initial, .error:
                mindfulMinutes = 0
            case let .mindfulMinutes(minutes):
                mindfulMinutes = minutes
            }
            let fraction = min(Float(mindfulMinutes / UserDefaults.standard.double(forKey: "intention")), 1)
            let provider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: Colors().foregoundUIColor, fillFraction: fraction)
            let activeMinutes = CLKSimpleTextProvider(text: "\(Int(mindfulMinutes))")
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeText(gaugeProvider: provider, centerTextProvider: activeMinutes)
            handler(CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template))
        default:
            handler(nil)
        }
    }
}
