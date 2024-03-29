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
    case welcome = "Practice meditation with your favourite App that supports Apple Health and mind your mental well being"
    case info = "Keep track of your daily Mindful Minutes with the supported Complications on your Apple Watch"
    case permission = "Please allow the App to access your Mindful Minutes from Apple Health"
    case review = "Review"
    
    // Intention
    case mindful = "Mindful"
    case dailyIntention = "Your Daily Intention"
    case minutes = "Minutes"
    case minute = "Minute"
    case mindfulMinutes = "Mindful Minutes"
    case intention = "Intention"
    case setYourIntention = "Set Your Intention"
    case guidedInfoText = "By enabling guided meditation, you will perceive subtle haptics each minute"

    // Meditation
    case unguided = "Unguided"
    case guided = "Guided"
    case meditation = "Meditation"
    case start = "Start"
    case done = "Done"
    case guidedMeditation = "Guided Meditation"
    
    // Error
    case unavailable = "Your Device doesn't support Apple Health :("
    case noDataAvailable = "Couldn't load Data from Apple Health :("
    case ctaOpenSettings = "Please allow Intention to access your mindful Session in the Settings"
    case savingFailed = "Saving your mindful Session failed :("
    
    var localisation: LocalizedStringKey {
        return self.rawValue
    }
}
