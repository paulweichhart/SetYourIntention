//
//  ComplicationController.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import ClockKit
import Combine
import Foundation

class ComplicationController: NSObject, CLKComplicationDataSource {

    private var cancellable = Set<AnyCancellable>()
    
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

            Store.shared.mindfulMinutes()
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] storeState in
                    if case .failure = storeState {
                        handler(self?.createTimelineEntry(mindfulMinutes: 0))
                    }
                }, receiveValue: { [weak self] mindfulMinutes in
                    handler(self?.createTimelineEntry(mindfulMinutes: mindfulMinutes))
                })
                .store(in: &cancellable)
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
