//
//  WhyPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct WhyPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    @State private var otherText = ""
    
    init(onboardingData: Binding<OnboardingData>, currentPage: Binding<Int>) {
        self._onboardingData = onboardingData
        self._currentPage = currentPage
        
        // Initialize otherText if there's already an "Other: ..." entry
        let existingOther = onboardingData.wrappedValue.whyOptions.first { $0.hasPrefix("Other:") }
        if let existing = existingOther {
            self._otherText = State(initialValue: String(existing.dropFirst(6))) // Remove "Other: " prefix
        }
    }
    
    private let whyOptions = [
        "Grow my career",
        "Find mentors/advisors",
        "Stay relevant in conversations",
        "Meet new people",
        "Organize my network",
        "Explore opportunities"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What brings you to Rolo today? (Pick as many as you like)")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                ForEach(whyOptions, id: \.self) { option in
                    Chip(
                        text: option,
                        isSelected: onboardingData.whyOptions.contains(option)
                    ) {
                        if onboardingData.whyOptions.contains(option) {
                            onboardingData.whyOptions.remove(option)
                        } else {
                            onboardingData.whyOptions.insert(option)
                        }
                    }
                }
                
                // Other option with text input
                Chip(
                    text: "Other",
                    isSelected: onboardingData.whyOptions.contains("Other") || !otherText.isEmpty
                ) {
                    if onboardingData.whyOptions.contains("Other") || !otherText.isEmpty {
                        onboardingData.whyOptions.remove("Other")
                        // Remove any "Other: ..." entries
                        onboardingData.whyOptions = onboardingData.whyOptions.filter { !$0.hasPrefix("Other:") }
                        otherText = ""
                    } else {
                        onboardingData.whyOptions.insert("Other")
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // Other text input (show when Other is selected or has text)
            if onboardingData.whyOptions.contains("Other") || !otherText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us more:")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 24)
                    
                    TextField("What brings you to Rolo?", text: $otherText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 24)
                        .onChange(of: otherText) { newValue in
                            // Remove any existing "Other: ..." entries
                            onboardingData.whyOptions = onboardingData.whyOptions.filter { !$0.hasPrefix("Other:") }
                            
                            // Add the custom text if not empty
                            if !newValue.isEmpty {
                                onboardingData.whyOptions.insert("Other: \(newValue)")
                            }
                        }
                }
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button("Back") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 3
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 5
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
