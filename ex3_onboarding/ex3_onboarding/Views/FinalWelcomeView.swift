//
//  FinalWelcomeView.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct FinalWelcomeView: View {
    @Binding var showFinalWelcome: Bool
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color(red: 0.357, green: 0.549, blue: 1.0), Color(red: 0.486, green: 0.302, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Welcome to Rolo 🚀")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("You're all set to grow your network with purpose.")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button(action: {
                    // Dismiss onboarding and enter main app
                    showFinalWelcome = false
                }) {
                    Text("Enter Rolo")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(16)
                        .scaleEffect(1.0)
                        .animation(.easeOut(duration: 0.1), value: false)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
    }
}
