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

    private let mindfulTimeIntervalKey = "mindfulTimeInterval"

    private var intention: TimeInterval {
        return Store.shared.state.intention
    }

    func complicationDescriptors() async -> [CLKComplicationDescriptor] {
        return [CLKComplicationDescriptor(identifier: "complication",
                                          displayName: "Intention",
                                          supportedFamilies: [.circularSmall,
                                                              .extraLarge,
                                                              .graphicBezel,
                                                              .graphicCircular,
                                                              .graphicCorner,
                                                              .graphicExtraLarge,
                                                              .modularSmall,
                                                              .utilitarianSmall])]
    }

    func privacyBehavior(for complication: CLKComplication) async -> CLKComplicationPrivacyBehavior {
        return .hideOnLockScreen
    }

    func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
        await Store.shared.dispatch(action: .requestHealthStorePermission)
        await Store.shared.dispatch(action: .fetchMindfulTimeInterval)

        switch Store.shared.state.mindfulState {
        case let .loaded(timeInterval):
            return complicationTimelineEntry(mindfulTimeInterval: timeInterval,
                                             intention: intention,
                                             progress: Store.shared.state.mindfulStateProgress ?? 0,
                                             family: complication.family)
        case .loading, .error:
            return complicationTimelineEntry(mindfulTimeInterval: 0,
                                             intention: intention,
                                             progress: 0,
                                             family: complication.family)
        }
    }

    private func complicationTimelineEntry(mindfulTimeInterval: TimeInterval, intention: TimeInterval, progress: Double, family: CLKComplicationFamily) -> CLKComplicationTimelineEntry? {
        let image = family.asset ?? UIImage()
        let fraction = min(Float(progress), 1)
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
