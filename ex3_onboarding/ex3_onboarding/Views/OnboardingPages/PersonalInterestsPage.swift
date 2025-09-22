//
//  PersonalInterestsPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct PersonalInterestsPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    @State private var selectedInterests: Set<String> = []
    @State private var customInterest: String = ""
    
    private let suggestedInterests = [
        "Sports", "Music", "Art", "Travel", "Cooking", "Photography", 
        "Reading", "Gaming", "Fitness", "Movies", "Hiking", "Dancing",
        "Volunteering", "Gardening", "Writing", "Meditation", "Yoga"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beyond work, who are you? What makes you, you?")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Personal Interests Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Personal Interests")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        // Custom interest input
                        HStack {
                            TextField("+ Add your own interest", text: $customInterest)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    if !customInterest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        selectedInterests.insert(customInterest.trimmingCharacters(in: .whitespacesAndNewlines))
                                        customInterest = ""
                                    }
                                }
                            
                            Button("Add") {
                                if !customInterest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    selectedInterests.insert(customInterest.trimmingCharacters(in: .whitespacesAndNewlines))
                                    customInterest = ""
                                }
                            }
                            .disabled(customInterest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        // All interests (suggested + custom)
                        let allInterests = suggestedInterests + Array(selectedInterests).filter { !suggestedInterests.contains($0) }
                        if !allInterests.isEmpty {
                            FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                                ForEach(allInterests, id: \.self) { interest in
                                    Chip(
                                        text: interest,
                                        isSelected: selectedInterests.contains(interest)
                                    ) {
                                        if selectedInterests.contains(interest) {
                                            selectedInterests.remove(interest)
                                        } else {
                                            selectedInterests.insert(interest)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 100)
                
                // Navigation buttons
                HStack(spacing: 16) {
                    Button("Back") {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentPage = 10
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    GradientButton(title: "Next ▸") {
                        // Save selected suggested interests to onboarding data
                        onboardingData.personalInterests.append(contentsOf: selectedInterests)
                        
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentPage = 12
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}


