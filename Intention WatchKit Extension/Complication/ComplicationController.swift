//
//  ComplicationController.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import ClockKit


final class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration

//    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
//        let descriptors = [
//            CLKComplicationDescriptor(identifier: "complication", displayName: "Intention", supportedFamilies: [.circularSmall, .graphicCircular])
//        ]
//        handler(descriptors)
//    }

    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.hideOnLockScreen)
    }
    
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
}
