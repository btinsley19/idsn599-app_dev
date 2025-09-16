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
    case 6...7: return .yourGoals         // Goals, Strengths
    case 8...10: return .yourHabits       // Info Sources, Interests, Networking
    case 11...12: return .finalTouch      // Final Reflection, Personal Plan
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
        // Pages 6-7: 30% to 50% of total progress
        switch page {
        case 6: return 0.3
        case 7: return 0.5
        default: return 0.3
        }
    case .yourHabits:
        // Pages 8-10: 50% to 80% of total progress
        switch page {
        case 8: return 0.5
        case 9: return 0.65
        case 10: return 0.8
        default: return 0.5
        }
    case .finalTouch:
        // Pages 11-12: 80% to 100% of total progress
        switch page {
        case 11: return 0.8
        case 12: return 1.0
        default: return 0.8
        }
    }
}

func getOverallProgress(for page: Int) -> Double {
    // Calculate overall progress across all pages (3-12)
    let totalPages = 10 // Pages 3 through 12
    let currentPageIndex = page - 3 // Convert to 0-based index
    return Double(currentPageIndex) / Double(totalPages - 1)
}

func isMilestoneCompleted(for page: Int) -> Bool {
    // A milestone is completed when we've moved to the next milestone
    switch page {
    case 5...12: // After Getting to Know You (pages 3-4)
        return true
    case 7...12: // After Your Goals (pages 5-6)
        return true
    case 10...12: // After Your Habits (pages 7-9)
        return true
    case 12: // After Final Touch (pages 10-12)
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
    if page >= 8 { // After Your Goals (pages 6-7: Goals, Strengths)
        completed.insert(.yourGoals)
    }
    if page >= 11 { // After Your Habits (pages 8-10: Info Sources, Interests, Networking)
        completed.insert(.yourHabits)
    }
    if page >= 12 { // After Final Touch (pages 11-12: Final Reflection, Personal Plan)
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
