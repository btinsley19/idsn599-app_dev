//
//  LongTermGoalsPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct LongTermGoalsPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    @State private var selectedGoals: Set<String> = []
    @State private var customGoal: String = ""
    
    private let suggestedGoals = [
        "Start a venture",
        "Get promoted",
        "Switch industries",
        "Grow my network",
        "Speak with more confidence",
        "Be more interesting / knowledgeable"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What are your long-term aspirations?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Think big picture - where do you see yourself in 2-5 years? These dreams will guide your learning journey.")
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
                        currentPage = 6
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    // Save selected goals to onboarding data
                    onboardingData.longTermGoals.append(contentsOf: selectedGoals)
                    
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 8
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

