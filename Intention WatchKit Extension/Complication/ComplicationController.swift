//
//  ComplicationController.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 18.10.20.
//

import ClockKit
import Combine
import Foundation

final class ComplicationController: NSObject, CLKComplicationDataSource {
    
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
        let healthStore = HealthStore()
        let intention = AppState().intention
        Task {
            do {
                try await healthStore.requestPermission()
                let timeInterval = try await healthStore.fetchMindfulTimeInterval()
                handler(complicationTimelineEntry(mindfulTimeInterval: timeInterval,
                                                  intention: intention,
                                                  family: complication.family))
            } catch {
                handler(complicationTimelineEntry(mindfulTimeInterval: 0,
                                                  intention: intention,
                                                  family: complication.family))
            }
        }
    }

    private func complicationTimelineEntry(mindfulTimeInterval: TimeInterval, intention: TimeInterval, family: CLKComplicationFamily) -> CLKComplicationTimelineEntry? {
        let image = family.asset ?? UIImage()
        let fraction = min(Float(mindfulTimeInterval / intention), 1)
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                                   gaugeColor: UIColor(Colors.foreground.value),
                                                   fillFraction: fraction)
        let imageProvider = CLKImageProvider(onePieceImage: image)
        let fullColorImageProvider = CLKFullColorImageProvider(fullColorImage: image)

        let template: CLKComplicationTemplate
        switch family {
        case .circularSmall:
            template = CLKComplicationTemplateCircularSmallRingImage(imageProvider: imageProvider,
                                                                         fillFraction: fraction,
                                                                         ringStyle: .closed)
        case .extraLarge:
            template = CLKComplicationTemplateExtraLargeRingImage(imageProvider: imageProvider,
                                                                      fillFraction: fraction,
                                                                      ringStyle: .closed)
        case .graphicBezel:
            let gaugeImage = CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: gaugeProvider,
                                                                                    imageProvider: fullColorImageProvider)
            let localizedIntention = NSLocalizedString("Intention", comment: "")
            let localizedMindful = NSLocalizedString("Mindful", comment: "")
            let textProvider = CLKTextProvider(format: "\(localizedMindful) %dMin • \(localizedIntention) %dMin",
                                               Converter.minutes(from: mindfulTimeInterval),
                                               Converter.minutes(from: intention))
            template = CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: gaugeImage,
                                                                       textProvider: textProvider)
        case .graphicCircular:
            template = CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: gaugeProvider,
                                                                              imageProvider: fullColorImageProvider)
        case .graphicCorner:
            template = CLKComplicationTemplateGraphicCornerGaugeImage(gaugeProvider: gaugeProvider,
                                                                      imageProvider: fullColorImageProvider)
        case .graphicExtraLarge:
            template = CLKComplicationTemplateGraphicExtraLargeCircularClosedGaugeImage(gaugeProvider: gaugeProvider,
                                                                                        imageProvider: fullColorImageProvider)
        case .modularSmall:
            template = CLKComplicationTemplateModularSmallRingImage(imageProvider: imageProvider,
                                                                    fillFraction: fraction,
                                                                    ringStyle: .closed)
        case .utilitarianSmall:
            template = CLKComplicationTemplateUtilitarianSmallRingImage(imageProvider: imageProvider,
                                                                        fillFraction: fraction,
                                                                        ringStyle: .closed)
        default:
            return nil
        }
        return CLKComplicationTimelineEntry(date: Date(),
                                            complicationTemplate: template)
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
