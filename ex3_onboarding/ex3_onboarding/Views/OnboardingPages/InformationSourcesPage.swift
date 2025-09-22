//
//  InformationSourcesPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct InformationSourcesPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    @State private var customSourcesText = ""
    
    private let informationSourceOptions = InformationSource.allCases.map { $0.rawValue }
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How do you usually keep up with what matters? Select all that fit, and add a few of your go-to sources.")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Information Sources
                        VStack(alignment: .leading, spacing: 12) {
                            CheckboxList(
                                options: informationSourceOptions,
                                selectedOptions: $onboardingData.informationSources
                            )
                            
                            // Custom sources text input (always visible)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Drop in a few names — favorite podcasters, YouTubers, websites, or newsletters…")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                
                                TextField("e.g., The Daily, Lex Fridman, TechCrunch...", text: $customSourcesText, axis: .vertical)
                                    .padding(12)
                                    .background(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color(red: 0.357, green: 0.549, blue: 1.0), Color(red: 0.486, green: 0.302, blue: 1.0)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                                    .lineLimit(3...6)
                                    .onChange(of: customSourcesText) { newValue in
                                        // Parse comma-separated values
                                        let sources = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                        onboardingData.customSources = sources.filter { !$0.isEmpty }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Add some bottom padding to ensure content doesn't get cut off
                    Spacer(minLength: 20)
                }
            }
            
            // Fixed navigation buttons at bottom
            HStack(spacing: 16) {
                Button("Back") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 9
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 11
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .background(Color(.systemBackground))
        }
    }
}
