//
//  ValuePropTourView.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct ValuePropTourView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ValuePropPage(
                    headline: "Stay relevant, effortlessly.",
                    bullet1: "Surface timely news & talking points about people you care about.",
                    bullet2: "Show up prepared without the scramble.",
                    icon: "newspaper.fill",
                    currentPage: $currentPage
                )
                .tag(0)
                
                ValuePropPage(
                    headline: "Grow with purpose.",
                    bullet1: "Set goals and priorities—Rolo adapts recommendations to match.",
                    bullet2: "Nudges that respect your cadence.",
                    icon: "target",
                    currentPage: $currentPage
                )
                .tag(1)
                
                ValuePropPage(
                    headline: "Remember what matters.",
                    bullet1: "Capture notes, interests, and context—never lose the thread.",
                    bullet2: "Rolo learns what's important over time.",
                    icon: "brain.head.profile",
                    currentPage: $currentPage
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.25), value: currentPage)
            
            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentPage ? 1.2 : 1.0)
                        .animation(.easeOut(duration: 0.25), value: currentPage)
                }
            }
            .padding(.bottom, 40)
        }
    }
}
