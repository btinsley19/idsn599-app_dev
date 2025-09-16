//
//  ValuePropPage.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct ValuePropPage: View {
    let headline: String
    let bullet1: String
    let bullet2: String
    let icon: String
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: icon)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            // Headline
            Text(headline)
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
            
            // Bullet points
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    
                    Text(bullet1)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.top, 2)
                    
                    Text(bullet2)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: 16) {
                if currentPage > 0 {
                    Button("Back") {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentPage -= 1
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if currentPage < 2 {
                    GradientButton(title: "Next ▸") {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentPage += 1
                        }
                    }
                } else {
                    GradientButton(title: "Get Started") {
                        withAnimation(.easeOut(duration: 0.25)) {
                            currentPage = 3 // Move to onboarding flow
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}
