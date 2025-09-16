//
//  Enums.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import Foundation

enum CurrentJourney: String, CaseIterable {
    case student = "Student"
    case earlyCareer = "Early career"
    case buildingCompany = "Building a company"
    case careerTransition = "Career transition"
    case exploring = "Exploring"
}

enum InformationSource: String, CaseIterable {
    case podcasts = "🎧 Podcasts"
    case youtube = "📺 YouTube"
    case articles = "📰 Articles/News sites"
    case newsletters = "📩 Newsletters"
    case other = "🎤 Other"
}

enum NetworkingStyle: String, CaseIterable {
    case events = "Events"
    case coldOutreach = "Cold outreach"
    case socialMedia = "Social media"
    case friendsReferrals = "Friends & referrals"
    case communities = "Communities/clubs"
    case other = "Other"
}

enum OnboardingMilestone: String, CaseIterable {
    case gettingToKnowYou = "Getting to Know You"
    case yourGoals = "Your Goals"
    case yourHabits = "Your Habits"
    case finalTouch = "Final Touch"
}
