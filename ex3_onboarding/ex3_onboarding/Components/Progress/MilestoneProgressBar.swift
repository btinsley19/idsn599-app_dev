//
//  MilestoneProgressBar.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct MilestoneProgressBar: View {
    let currentPage: Int
    @State private var showConfetti = false
    @State private var completedMilestones: Set<OnboardingMilestone> = []
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.357, green: 0.549, blue: 1.0), Color(red: 0.486, green: 0.302, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * getOverallProgress(for: currentPage), height: 8)
                        .animation(.easeOut(duration: 0.5), value: currentPage)
                        .overlay(
                            // Glow effect
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.357, green: 0.549, blue: 1.0), Color(red: 0.486, green: 0.302, blue: 1.0)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .blur(radius: 4)
                                .opacity(showConfetti ? 0.8 : 0.0)
                                .animation(.easeOut(duration: 0.3), value: showConfetti)
                        )
                }
            }
            .frame(height: 8)
            
            // Milestone labels
            HStack {
                ForEach(OnboardingMilestone.allCases, id: \.self) { milestone in
                    HStack(spacing: 4) {
                        Text(milestone.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(getMilestoneLabelColor(for: milestone, currentPage: currentPage))
                            .animation(.easeOut(duration: 0.25), value: currentPage)
                        
                        // Checkmark for completed milestones
                        if getCompletedMilestones(for: currentPage).contains(milestone) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                                .scaleEffect(showConfetti ? 1.2 : 1.0)
                                .animation(.easeOut(duration: 0.3), value: showConfetti)
                        }
                    }
                    
                    if milestone != OnboardingMilestone.allCases.last {
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: currentPage) { _ in
            // Check for new milestone completions and trigger animations
            let newCompletedMilestones = getCompletedMilestones(for: currentPage)
            let newlyCompleted = newCompletedMilestones.subtracting(completedMilestones)
            
            if !newlyCompleted.isEmpty {
                completedMilestones = newCompletedMilestones
                showConfetti = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showConfetti = false
                }
            }
        }
    }
}
