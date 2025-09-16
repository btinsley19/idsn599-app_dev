//
//  CardSelection.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct CardSelection: View {
    let options: [String]
    @Binding var selectedOption: String
    @State private var pressedCard: String? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(option)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(selectedOption == option ? .white : .primary)
                            
                            Text(getDescription(for: option))
                                .font(.system(size: 14))
                                .foregroundColor(selectedOption == option ? .white.opacity(0.8) : .secondary)
                        }
                        
                        Spacer()
                        
                        if selectedOption == option {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if selectedOption == option {
                                LinearGradient(
                                    colors: [Color(red: 0.357, green: 0.549, blue: 1.0), Color(red: 0.486, green: 0.302, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                Color(.systemGray6)
                            }
                        }
                    )
                    .cornerRadius(16)
                    .scaleEffect(pressedCard == option ? 0.96 : 1.0)
                    .animation(.easeOut(duration: 0.1), value: pressedCard)
                }
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    pressedCard = pressing ? option : nil
                }, perform: {})
            }
        }
    }
    
    private func getDescription(for option: String) -> String {
        switch option {
        case "Student": return "Learning and building foundational skills"
        case "Early career": return "First few years in the workforce"
        case "Building a company": return "Entrepreneur or startup founder"
        case "Career transition": return "Changing roles or industries"
        case "Exploring": return "Discovering new opportunities"
        default: return ""
        }
    }
}
