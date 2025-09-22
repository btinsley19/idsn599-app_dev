//
//  FinalReflectionPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct FinalReflectionPage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Is there anything else we should know to get the full picture of you and your goals?")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        // Final Reflection Section
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Tell us anything else that would help us understand you better...", text: $onboardingData.finalReflection, axis: .vertical)
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
                                .lineLimit(4...8)
                        }
                        
                        // File Upload Section
                        VStack(alignment: .leading, spacing: 12) {
                            FileUploadCard(isUploaded: $onboardingData.isFileUploaded)
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
                        currentPage = 12
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                
                Spacer()
                
                GradientButton(title: "Next ▸") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 14
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .background(Color(.systemBackground))
        }
    }
}
