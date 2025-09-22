//
//  ProgressUtils.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import Foundation
import SwiftUI

func getCurrentMilestone(for page: Int) -> OnboardingMilestone {
    switch page {
    case 3...5: return .gettingToKnowYou  // Name, Why, Current Journey
    case 6...9: return .yourGoals         // Short-term Goals, Long-term Goals, Strengths, Growth Areas
    case 10...12: return .yourHabits      // Info Sources, Interests, Networking
    case 13...14: return .finalTouch      // Final Reflection, Personal Plan
    default: return .gettingToKnowYou
    }
}

func getMilestoneProgress(for page: Int) -> Double {
    let milestone = getCurrentMilestone(for: page)
    switch milestone {
    case .gettingToKnowYou:
        // Pages 3-5: 0% to 30% of total progress
        switch page {
        case 3: return 0.0
        case 4: return 0.15
        case 5: return 0.3
        default: return 0.0
        }
    case .yourGoals:
        // Pages 6-9: 30% to 50% of total progress
        switch page {
        case 6: return 0.3
        case 7: return 0.35
        case 8: return 0.4
        case 9: return 0.5
        default: return 0.3
        }
    case .yourHabits:
        // Pages 10-12: 50% to 80% of total progress
        switch page {
        case 10: return 0.5
        case 11: return 0.65
        case 12: return 0.8
        default: return 0.5
        }
    case .finalTouch:
        // Pages 13-14: 80% to 100% of total progress
        switch page {
        case 13: return 0.8
        case 14: return 1.0
        default: return 0.8
        }
    }
}

func getOverallProgress(for page: Int) -> Double {
    // Calculate overall progress across all pages (3-14)
    let totalPages = 12 // Pages 3 through 14
    let currentPageIndex = page - 3 // Convert to 0-based index
    return Double(currentPageIndex) / Double(totalPages - 1)
}

func isMilestoneCompleted(for page: Int) -> Bool {
    // A milestone is completed when we've moved to the next milestone
    switch page {
    case 5...14: // After Getting to Know You (pages 3-5)
        return true
    case 9...14: // After Your Goals (pages 6-9)
        return true
    case 12...14: // After Your Habits (pages 10-12)
        return true
    case 14: // After Final Touch (pages 13-14)
        return true
    default:
        return false
    }
}

func getCompletedMilestones(for page: Int) -> Set<OnboardingMilestone> {
    // Return all milestones that have been completed by this page
    var completed: Set<OnboardingMilestone> = []
    
    if page >= 6 { // After Getting to Know You (pages 3-5: Name, Why, Current Journey)
        completed.insert(.gettingToKnowYou)
    }
    if page >= 10 { // After Your Goals (pages 6-9: Short-term Goals, Long-term Goals, Strengths, Growth Areas)
        completed.insert(.yourGoals)
    }
    if page >= 13 { // After Your Habits (pages 10-12: Info Sources, Interests, Networking)
        completed.insert(.yourHabits)
    }
    if page >= 14 { // After Final Touch (pages 13-14: Final Reflection, Personal Plan)
        completed.insert(.finalTouch)
    }
    
    return completed
}

func getMilestoneLabelColor(for milestone: OnboardingMilestone, currentPage: Int) -> Color {
    let currentMilestone = getCurrentMilestone(for: currentPage)
    let completedMilestones = getCompletedMilestones(for: currentPage)
    
    if completedMilestones.contains(milestone) {
        return .green
    } else if currentMilestone == milestone {
        return .blue
    } else {
        return .secondary
    }
}
