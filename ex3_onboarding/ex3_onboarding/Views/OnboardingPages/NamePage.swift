//
//  NamePage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct NamePage: View {
    @Binding var onboardingData: OnboardingData
    @Binding var currentPage: Int
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Let's get personal. What should we call you?")
                    .font(.system(size: 28, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 24)
            }
            
            VStack(spacing: 20) {
                TextField("Enter your name", text: $onboardingData.name)
                    .font(.system(size: 18))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 24)
                    .onSubmit {
                        if !onboardingData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            withAnimation(.easeOut(duration: 0.25)) {
                                currentPage = 4
                            }
                        }
                    }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                GradientButton(title: "Next ▸") {
                    withAnimation(.easeOut(duration: 0.25)) {
                        currentPage = 4
                    }
                }
                .disabled(onboardingData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(onboardingData.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
}
