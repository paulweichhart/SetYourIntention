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
                    let minutes = Minutes(mindful: 0, intention: intention)
                    if let template = self?.complicationTemplate(minutes: minutes, family: complication.family) {
                        handler(CLKComplicationTimelineEntry(date: Date(),
                                                             complicationTemplate: template))
                    } else {
                        handler(nil)
                    }
                }
            }, receiveValue: { [weak self] mindfulMinutes in
                let minutes = Minutes(mindful: mindfulMinutes, intention: intention)
                if let template = self?.complicationTemplate(minutes: minutes, family: complication.family) {
                    handler(CLKComplicationTimelineEntry(date: Date(),
                                                        complicationTemplate: template))
                } else {
                    handler(nil)
                }
            })
            .store(in: &cancellable)
    }

    private func complicationTemplate(minutes: Minutes, family: CLKComplicationFamily) -> CLKComplicationTemplate? {
        let image = family.asset ?? UIImage()
        let gaugeProvider = CLKSimpleGaugeProvider(style: .fill,
                                              gaugeColor: UIColor(Colors.foreground.value),
                                              fillFraction: minutes.fraction)
        let imageProvider = CLKImageProvider(onePieceImage: image)
        let fullColorImageProvider = CLKFullColorImageProvider(fullColorImage: image)

        switch family {
        case .circularSmall:
            return CLKComplicationTemplateCircularSmallRingImage(imageProvider: imageProvider,
                                                                 fillFraction: minutes.fraction,
                                                                 ringStyle: .closed)
        case .extraLarge:
            return CLKComplicationTemplateExtraLargeRingImage(imageProvider: imageProvider,
                                                              fillFraction: minutes.fraction,
                                                              ringStyle: .closed)
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: gaugeProvider,
                                                                                  imageProvider: fullColorImageProvider)
            let localizedIntention = NSLocalizedString("Intention", comment: "")
            let localizedMindful = NSLocalizedString("Mindful", comment: "")
            let textProvider = CLKTextProvider(format: "\(localizedMindful) %dMin • \(localizedIntention) %dMin", Int(minutes.mindful), Int(minutes.intention))
            return CLKComplicationTemplateGraphicBezelCircularText(circularTemplate: template,
                                                                   textProvider: textProvider)
        case .graphicCircular:
            return CLKComplicationTemplateGraphicCircularClosedGaugeImage(gaugeProvider: gaugeProvider,
                                                                          imageProvider: fullColorImageProvider)
        case .graphicCorner:
            return CLKComplicationTemplateGraphicCornerGaugeImage(gaugeProvider: gaugeProvider,
                                                                  imageProvider: fullColorImageProvider)
        case .graphicExtraLarge:
            return CLKComplicationTemplateGraphicExtraLargeCircularClosedGaugeImage(gaugeProvider: gaugeProvider,
                                                                                    imageProvider: fullColorImageProvider)
        case .modularSmall:
            return CLKComplicationTemplateModularSmallRingImage(imageProvider: imageProvider,
                                                                fillFraction: minutes.fraction,
                                                                ringStyle: .closed)
        case .utilitarianSmall:
            return CLKComplicationTemplateUtilitarianSmallRingImage(imageProvider: imageProvider,
                                                                    fillFraction: minutes.fraction,
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
