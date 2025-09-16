//
//  CheckboxList.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct CheckboxList: View {
    let options: [String]
    @Binding var selectedOptions: Set<String>
    @State private var pressedOption: String? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if selectedOptions.contains(option) {
                        selectedOptions.remove(option)
                    } else {
                        selectedOptions.insert(option)
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: selectedOptions.contains(option) ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundColor(selectedOptions.contains(option) ? .blue : .secondary)
                        
                        Text(option)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .scaleEffect(pressedOption == option ? 0.96 : 1.0)
                    .animation(.easeOut(duration: 0.1), value: pressedOption)
                }
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    pressedOption = pressing ? option : nil
                }, perform: {})
            }
        }
    }
}
