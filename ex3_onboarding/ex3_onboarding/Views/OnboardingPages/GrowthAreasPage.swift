//
//  GrowthAreasPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct GrowthAreasPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    @State private var selectedGrowthAreas: Set<String> = []
    @State private var customGrowthArea: String = ""
    
    private let suggestedGrowthAreas = [
        "Public Speaking",
        "Data Analysis",
        "Leadership",
        "Technical Skills",
        "Networking",
        "Time Management",
        "Strategic Thinking",
        "Communication"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What would you love to get better at?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("These are the skills and areas where you want to grow. Rolo will help you develop these through personalized content and connections.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
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
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button("Back") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 8
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    // Save selected growth areas to onboarding data
                    onboardingData.growthAreas.append(contentsOf: selectedGrowthAreas)
                    
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 10
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

