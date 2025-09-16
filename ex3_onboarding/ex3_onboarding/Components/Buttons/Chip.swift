//
//  Chip.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct Chip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: true)   // prevents compression/ellipsis
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if isSelected {
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
                .cornerRadius(12)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.easeOut(duration: 0.1), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
