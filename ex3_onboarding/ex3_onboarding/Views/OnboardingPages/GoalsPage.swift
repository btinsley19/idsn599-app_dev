//
//  GoalsPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct GoalsPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    @State private var selectedShortTermGoals: Set<String> = []
    @State private var selectedLongTermGoals: Set<String> = []
    @State private var customShortTermGoal: String = ""
    @State private var customLongTermGoal: String = ""
    
    private let shortTermExamples = [
        "Land a new role",
        "Learn more about a topic",
        "Get a mentor",
        "Close more deals"
    ]
    
    private let longTermExamples = [
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
                Text("Dream a little. Where do you want to go next?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("This will help Rolo craft a personalized plan for you to become your best self. You can edit this later.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Short-term goals")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    // Custom goal input
                    HStack {
                        TextField("+ Add your own goal", text: $customShortTermGoal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                if !customShortTermGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    selectedShortTermGoals.insert(customShortTermGoal.trimmingCharacters(in: .whitespacesAndNewlines))
                                    customShortTermGoal = ""
                                }
                            }
                        
                        Button("Add") {
                            if !customShortTermGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectedShortTermGoals.insert(customShortTermGoal.trimmingCharacters(in: .whitespacesAndNewlines))
                                customShortTermGoal = ""
                            }
                        }
                        .disabled(customShortTermGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // All goals (suggested + custom)
                    let allShortTermGoals = shortTermExamples + Array(selectedShortTermGoals).filter { !shortTermExamples.contains($0) }
                    if !allShortTermGoals.isEmpty {
                        FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                            ForEach(allShortTermGoals, id: \.self) { goal in
                                Chip(
                                    text: goal,
                                    isSelected: selectedShortTermGoals.contains(goal)
                                ) {
                                    if selectedShortTermGoals.contains(goal) {
                                        selectedShortTermGoals.remove(goal)
                                    } else {
                                        selectedShortTermGoals.insert(goal)
                                    }
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Long-term goals")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    // Custom goal input
                    HStack {
                        TextField("+ Add your own goal", text: $customLongTermGoal)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                if !customLongTermGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    selectedLongTermGoals.insert(customLongTermGoal.trimmingCharacters(in: .whitespacesAndNewlines))
                                    customLongTermGoal = ""
                                }
                            }
                        
                        Button("Add") {
                            if !customLongTermGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectedLongTermGoals.insert(customLongTermGoal.trimmingCharacters(in: .whitespacesAndNewlines))
                                customLongTermGoal = ""
                            }
                        }
                        .disabled(customLongTermGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // All goals (suggested + custom)
                    let allLongTermGoals = longTermExamples + Array(selectedLongTermGoals).filter { !longTermExamples.contains($0) }
                    if !allLongTermGoals.isEmpty {
                        FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                            ForEach(allLongTermGoals, id: \.self) { goal in
                                Chip(
                                    text: goal,
                                    isSelected: selectedLongTermGoals.contains(goal)
                                ) {
                                    if selectedLongTermGoals.contains(goal) {
                                        selectedLongTermGoals.remove(goal)
                                    } else {
                                        selectedLongTermGoals.insert(goal)
                                    }
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
                    // Save selected suggested goals to onboarding data
                    onboardingData.shortTermGoals.append(contentsOf: selectedShortTermGoals)
                    onboardingData.longTermGoals.append(contentsOf: selectedLongTermGoals)
                    
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
