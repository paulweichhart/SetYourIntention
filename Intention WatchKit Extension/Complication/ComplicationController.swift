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
                                       supportedFamilies: [.circularSmall,
                                                           .extraLarge,
                                                           .graphicBezel,
                                                           .graphicCircular,
                                                           .graphicCorner,
                                                           .graphicExtraLarge,
                                                           .modularSmall,
                                                           .utilitarianSmall])
         ]
         handler(descriptors)
     }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.hideOnLockScreen)
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {

        let intention = Intention().minutes
        Store.shared.mindfulMinutes()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] storeState in
                if case .failure = storeState {
                    if let template = self?.complicationTemplate(mindfulMinutes: 0, intention: intention, family: complication.family) {
                        handler(CLKComplicationTimelineEntry(date: Date(),
                                                             complicationTemplate: template))
                    } else {
                        handler(nil)
                    }
                }
            }, receiveValue: { [weak self] mindfulMinutes in
                if let template = self?.complicationTemplate(mindfulMinutes: mindfulMinutes, intention: intention, family: complication.family) {
                    handler(CLKComplicationTimelineEntry(date: Date(),
                                                        complicationTemplate: template))
                } else {
                    handler(nil)
                }
            })
            .store(in: &cancellable)
    }

    private func complicationTemplate(mindfulMinutes: Double, intention: Double, family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let fraction = min(Float(mindfulMinutes / intention), 1)
        let image = family.asset ?? UIImage()

        let provider = CLKSimpleGaugeProvider(style: .fill,
                                              gaugeColor: UIColor(Colors.foreground.value),
                                              fillFraction: fraction)
        let imageProvider = CLKImageProvider(onePieceImage: image)
        let fullColorImageProvider = CLKFullColorImageProvider(fullColorImage: image)

        switch family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallRingImage(imageProvider: imageProvider,
                                                                 fillFraction: fraction,
                                                                 ringStyle: .closed)
        case .extraLarge:
            return CLKComplicationTemplateExtraLargeRingImage(imageProvider: imageProvider,
                                                              fillFraction: fraction,
                                                              ringStyle: .closed)
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: provider,
                                                                                  imageProvider: fullColorImageProvider)
            let localizedIntention = NSLocalizedString("Intention", comment: "")
            let localizedMindful = NSLocalizedString("Mindful", comment: "")
            let textProvider = CLKTextProvider(format: "\(localizedMindful) %dMin • \(localizedIntention) %dMin", Int(mindfulMinutes), Int(intention))
            return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: template,
                                                                   textProvider: textProvider)
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: provider,
                                                                          imageProvider: fullColorImageProvider)
        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerGaugeImage(gaugeProvider: provider,
                                                                  imageProvider: fullColorImageProvider)
        case .graphicExtraLarge:
            return CLKComplicationTemplateGraphicExtraLargeCircularClosedGaugeImage(gaugeProvider: provider,
                                                                                    imageProvider: fullColorImageProvider)
        case .modularSmall:
            return CLKComplicationTemplateModularSmallRingImage(imageProvider: imageProvider,
                                                                fillFraction: fraction,
                                                                ringStyle: .closed)
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallRingImage(imageProvider: imageProvider,
                                                                    fillFraction: fraction,
                                                                    ringStyle: .closed)
        default:
            return nil
        }
    }
}

extension CLKComplicationFamily {

    static let directory = "Complication/"

    var asset: UIImage? {
        let asset: String
        switch self {
        case .circularSmall:
            asset = "Circular"
        case .extraLarge:
            asset = "Extra Large"
        case .graphicBezel:
            asset = "Graphic Bezel"
        case .graphicCircular:
            asset = "Graphic Circular"
        case .graphicCorner:
            asset = "Graphic Corner"
        case .graphicExtraLarge:
            asset = "Graphic Extra Large"
        case .modularSmall:
            asset = "Modular"
        case .utilitarianSmall,
             .utilitarianSmallFlat:
            asset = "Utilitarian"
        default:
            return nil
        }
        return UIImage(named: Self.directory + asset)
    }
}
