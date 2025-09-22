//
//  ContentView.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @State private var currentPage = 0
    @State private var onboardingData = OnboardingData()
    @State private var showFinalWelcome = false
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            if showFinalWelcome {
                FinalWelcomeView(showFinalWelcome: $showFinalWelcome)
            } else if currentPage < 3 {
                // Pre-onboarding value prop tour
                ValuePropTourView(currentPage: $currentPage)
            } else {
                // Main onboarding flow
                VStack(spacing: 0) {
                    // Milestone progress bar
                    MilestoneProgressBar(currentPage: currentPage)
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                    
                    // TabView for onboarding pages
                    TabView(selection: $currentPage) {
                        NamePage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(3)
                        
                        WhyPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(4)
                        
                        CurrentJourneyPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(5)
                        
                        ShortTermGoalsPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(6)
                        
                        LongTermGoalsPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(7)
                        
                        StrengthsPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(8)
                        
                        GrowthAreasPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(9)
                        
                        InformationSourcesPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(10)
                        
                        PersonalInterestsPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(11)
                        
                        NetworkingStylePage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(12)
                        
                        FinalReflectionPage(onboardingData: $onboardingData, currentPage: $currentPage)
                            .tag(13)
                        
                        PersonalPlanPage(onboardingData: $onboardingData, showFinalWelcome: $showFinalWelcome)
                            .tag(14)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeOut(duration: 0.25), value: currentPage)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}