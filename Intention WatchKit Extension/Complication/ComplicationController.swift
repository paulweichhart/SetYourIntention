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
                                       supportedFamilies: [.graphicCircular])
         ]
         handler(descriptors)
     }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {

        switch complication.family {
        case .graphicCircular:

            switch Store.shared.mindfulMinutes {
            case .failure, .none:
                handler(createTimelineEntry(mindfulMinutes: 0))
            case let .success(minutes):
                handler(createTimelineEntry(mindfulMinutes: minutes))
            }
        default:
            handler(nil)
        }
    }
    
    private func createTimelineEntry(mindfulMinutes: Double) -> CLKComplicationTimelineEntry {
        let fraction = min(Float(mindfulMinutes / Intention().minutes), 1)
        let provider = CLKSimpleGaugeProvider(style: .fill,
                                              gaugeColor: UIColor(Colors.foreground.value),
                                              fillFraction: fraction)
        let image = UIImage(named: "Complication/Graphic Circular") ?? UIImage()
        let imageProvider = CLKFullColorImageProvider(fullColorImage: image)
        let template = CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: provider,
                                                                              imageProvider: imageProvider)
        return CLKComplicationTimelineEntry(date: Date(),
                                            complicationTemplate: template)
    }
}
