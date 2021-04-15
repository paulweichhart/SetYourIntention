//
//  Texts.swift
//  Intention WatchKit Extension
//
//  Created by Paul Weichhart on 20.03.21.
//

import Foundation
import SwiftUI

enum Texts: LocalizedStringKey {

    // Accessibility
    case progressInMinutes = "Progress in percentage"
    case intentionInMinutes = "Intention in Minutes"
    case increaseIntention = "Increase Intention"
    case decreaseIntention = "Decrease Intention"

    // Onboarding
    case welcome = "Use your preferred Meditation App with support for Apple Health and mind your mental well being"
    case info = "Keep track of your daily Mindful Minutes with the supported Complication on your Apple Watch"
    case permission = "Please allow the App to access your Mindful Minutes from Apple Health"
    case review = "Review"
    
    // Intention
    case dailyIntention = "Your Daily Intention"
    case minutes = "Minutes"
    case mindfulMinutes = "Mindful Minutes"
    case intention = "Intention"
    case setYourIntention = "Set Your Intention"
    
    // Error
    case unavailable = "Your Device doesn't support Apple Health :("
    case noDataAvailable = "Couldn't load Data from Apple Health :("
    case ctaOpenSettings = "Please allow Intention to access your mindful Session in the Settings"
    
    var localization: LocalizedStringKey {
        return self.rawValue
    }
}
