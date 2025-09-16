//
//  PersonalPlanPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct PersonalPlanPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var showFinalWelcome: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome, \(onboardingData.name.isEmpty ? "there" : onboardingData.name). Here's what Rolo learned about you 👇")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Goals Section
                    if !onboardingData.shortTermGoals.isEmpty || !onboardingData.longTermGoals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goals")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            if !onboardingData.shortTermGoals.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Short-term")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .leading) {
                                        ForEach(onboardingData.shortTermGoals, id: \.self) { goal in
                                            Text(goal)
                                                .font(.system(size: 14, weight: .medium))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            
                            if !onboardingData.longTermGoals.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Long-term")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .leading) {
                                        ForEach(onboardingData.longTermGoals, id: \.self) { goal in
                                            Text(goal)
                                                .font(.system(size: 14, weight: .medium))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.purple.opacity(0.1))
                                                .foregroundColor(.purple)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Strengths Section
                    if !onboardingData.strengths.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Strengths")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .leading) {
                                ForEach(onboardingData.strengths, id: \.self) { strength in
                                    Text(strength)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.green.opacity(0.1))
                                        .foregroundColor(.green)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Growth Areas Section
                    if !onboardingData.growthAreas.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Growth Areas")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .leading) {
                                ForEach(onboardingData.growthAreas, id: \.self) { area in
                                    Text(area)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.orange.opacity(0.1))
                                        .foregroundColor(.orange)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Personal Interests Section
                    if !onboardingData.personalInterests.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Personal Interests")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .leading) {
                                ForEach(onboardingData.personalInterests, id: \.self) { interest in
                                    Text(interest)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.pink.opacity(0.1))
                                        .foregroundColor(.pink)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Journey Stage
                    if !onboardingData.currentJourney.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Journey")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                                ForEach(Array(onboardingData.currentJourney), id: \.self) { journey in
                                    Text(journey)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            LinearGradient(
                                                colors: [Color(red: 0.357, green: 0.549, blue: 1.0), Color(red: 0.486, green: 0.302, blue: 1.0)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer(minLength: 100)
                
                VStack(spacing: 16) {
                    Text("We'll keep this evolving as you grow. Ready to get started?")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    GradientButton(title: "Let's Go →") {
                        showFinalWelcome = true
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
