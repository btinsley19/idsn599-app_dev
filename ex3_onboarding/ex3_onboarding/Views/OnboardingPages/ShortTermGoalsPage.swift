//
//  ShortTermGoalsPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct ShortTermGoalsPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    @State private var selectedGoals: Set<String> = []
    @State private var customGoal: String = ""
    
    private let suggestedGoals = [
        "Land a new role",
        "Learn more about a topic",
        "Get a mentor",
        "Close more deals"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What are your short-term goals?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Think about what you want to achieve in the next 6-12 months. This helps us create a focused plan for you.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                // Custom goal input
                HStack {
                    TextField("+ Add your own goal", text: $customGoal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            if !customGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectedGoals.insert(customGoal.trimmingCharacters(in: .whitespacesAndNewlines))
                                customGoal = ""
                            }
                        }
                    
                    Button("Add") {
                        if !customGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            selectedGoals.insert(customGoal.trimmingCharacters(in: .whitespacesAndNewlines))
                            customGoal = ""
                        }
                    }
                    .disabled(customGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                // All goals (suggested + custom)
                let allGoals = suggestedGoals + Array(selectedGoals).filter { !suggestedGoals.contains($0) }
                if !allGoals.isEmpty {
                    FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                        ForEach(allGoals, id: \.self) { goal in
                            Chip(
                                text: goal,
                                isSelected: selectedGoals.contains(goal)
                            ) {
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
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
                        currentPage = 5
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    // Save selected goals to onboarding data
                    onboardingData.shortTermGoals.append(contentsOf: selectedGoals)
                    
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 7
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

