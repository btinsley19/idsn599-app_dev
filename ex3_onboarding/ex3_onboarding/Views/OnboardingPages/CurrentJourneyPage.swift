//
//  CurrentJourneyPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct CurrentJourneyPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    private let journeyOptions = CurrentJourney.allCases.map { $0.rawValue }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Where are you in your journey?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                ForEach(journeyOptions, id: \.self) { option in
                    Chip(
                        text: option,
                        isSelected: onboardingData.currentJourney.contains(option)
                    ) {
                        if onboardingData.currentJourney.contains(option) {
                            onboardingData.currentJourney.remove(option)
                        } else {
                            onboardingData.currentJourney.insert(option)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button("Back") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 4
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 6
                    }
                }
                .disabled(onboardingData.currentJourney.isEmpty)
                .opacity(onboardingData.currentJourney.isEmpty ? 0.6 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
