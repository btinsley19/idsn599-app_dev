//
//  StrengthsPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct StrengthsPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    @State private var selectedStrengths: Set<String> = []
    @State private var selectedGrowthAreas: Set<String> = []
    @State private var customStrength: String = ""
    @State private var customGrowthArea: String = ""
    
    private let suggestedStrengths = [
        "Leadership", "Analytics", "Communication", "Problem Solving", 
        "Strategic Thinking", "Team Building"
    ]
    
    private let suggestedGrowthAreas = [
        "Public Speaking", "Data Analysis", "Leadership", "Technical Skills"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What are your superpowers? And what would you love to get better at?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Strengths (Current Knowledge)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    // Custom strength input
                    HStack {
                        TextField("+ Add your own strength", text: $customStrength)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                if !customStrength.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    selectedStrengths.insert(customStrength.trimmingCharacters(in: .whitespacesAndNewlines))
                                    customStrength = ""
                                }
                            }
                        
                        Button("Add") {
                            if !customStrength.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectedStrengths.insert(customStrength.trimmingCharacters(in: .whitespacesAndNewlines))
                                customStrength = ""
                            }
                        }
                        .disabled(customStrength.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // All strengths (suggested + custom)
                    let allStrengths = suggestedStrengths + Array(selectedStrengths).filter { !suggestedStrengths.contains($0) }
                    if !allStrengths.isEmpty {
                        FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                            ForEach(allStrengths, id: \.self) { strength in
                                Chip(
                                    text: strength,
                                    isSelected: selectedStrengths.contains(strength)
                                ) {
                                    if selectedStrengths.contains(strength) {
                                        selectedStrengths.remove(strength)
                                    } else {
                                        selectedStrengths.insert(strength)
                                    }
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Growth Areas (Want to Learn)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    // Custom growth area input
                    HStack {
                        TextField("+ Add your own growth area", text: $customGrowthArea)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onSubmit {
                                if !customGrowthArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    selectedGrowthAreas.insert(customGrowthArea.trimmingCharacters(in: .whitespacesAndNewlines))
                                    customGrowthArea = ""
                                }
                            }
                        
                        Button("Add") {
                            if !customGrowthArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectedGrowthAreas.insert(customGrowthArea.trimmingCharacters(in: .whitespacesAndNewlines))
                                customGrowthArea = ""
                            }
                        }
                        .disabled(customGrowthArea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    
                    // All growth areas (suggested + custom)
                    let allGrowthAreas = suggestedGrowthAreas + Array(selectedGrowthAreas).filter { !suggestedGrowthAreas.contains($0) }
                    if !allGrowthAreas.isEmpty {
                        FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                            ForEach(allGrowthAreas, id: \.self) { area in
                                Chip(
                                    text: area,
                                    isSelected: selectedGrowthAreas.contains(area)
                                ) {
                                    if selectedGrowthAreas.contains(area) {
                                        selectedGrowthAreas.remove(area)
                                    } else {
                                        selectedGrowthAreas.insert(area)
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
                        currentPage = 6
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    // Save selected suggested items to onboarding data
                    onboardingData.strengths.append(contentsOf: selectedStrengths)
                    onboardingData.growthAreas.append(contentsOf: selectedGrowthAreas)
                    
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
