//
//  NetworkingStylePage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct NetworkingStylePage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    @State private var selectedNetworkingStyles: Set<String> = []
    @State private var customNetworkingStyle: String = ""
    
    init(onboardingData: Binding<OnboardingData>, currentPage: Binding<Int>) {
        self._onboardingData = onboardingData
        self._currentPage = currentPage
        
        // Initialize selectedNetworkingStyles with existing data
        self._selectedNetworkingStyles = State(initialValue: onboardingData.wrappedValue.networkingStyle)
    }
    
    private let suggestedNetworkingStyles = [
        "Events", "Cold outreach", "Social media", "Friends & referrals", 
        "Communities/clubs", "Other"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("What's your style when it comes to building connections?")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                // Custom networking style input
                HStack {
                    TextField("+ Add your own style", text: $customNetworkingStyle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            if !customNetworkingStyle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                selectedNetworkingStyles.insert(customNetworkingStyle.trimmingCharacters(in: .whitespacesAndNewlines))
                                customNetworkingStyle = ""
                            }
                        }
                    
                    Button("Add") {
                        if !customNetworkingStyle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            selectedNetworkingStyles.insert(customNetworkingStyle.trimmingCharacters(in: .whitespacesAndNewlines))
                            customNetworkingStyle = ""
                        }
                    }
                    .disabled(customNetworkingStyle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                // All networking styles (suggested + custom)
                let allNetworkingStyles = suggestedNetworkingStyles + Array(selectedNetworkingStyles).filter { !suggestedNetworkingStyles.contains($0) }
                if !allNetworkingStyles.isEmpty {
                    FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                        ForEach(allNetworkingStyles, id: \.self) { style in
                            Chip(
                                text: style,
                                isSelected: selectedNetworkingStyles.contains(style)
                            ) {
                                if selectedNetworkingStyles.contains(style) {
                                    selectedNetworkingStyles.remove(style)
                                } else {
                                    selectedNetworkingStyles.insert(style)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .onChange(of: selectedNetworkingStyles) { newValue in
                // Keep onboarding data in sync with local state
                onboardingData.networkingStyle = newValue
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 16) {
                Button("Back") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 11
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 13
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
