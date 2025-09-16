//
//  OnboardingData.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import Foundation

struct OnboardingData {
    // New fields for updated flow
    var name: String = ""
    var whyOptions: Set<String> = []
    var currentJourney: Set<String> = []
    var shortTermGoals: [String] = []
    var longTermGoals: [String] = []
    var strengths: [String] = []
    var growthAreas: [String] = []
    var informationSources: Set<String> = []
    var customSources: [String] = []
    var networkingStyle: Set<String> = []
    var personalInterests: [String] = []
    var finalReflection: String = ""
    var isFileUploaded: Bool = false
}
