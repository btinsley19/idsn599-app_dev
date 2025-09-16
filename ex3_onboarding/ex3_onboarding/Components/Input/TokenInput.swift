//
//  TokenInput.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct Token: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: true)   // prevents compression/ellipsis
                .foregroundColor(.primary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TokenInput: View {
    @Binding var tokens: [String]
    let placeholder: String
    @State private var inputText = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Display existing tokens
            if !tokens.isEmpty {
                FlowLayout(hSpacing: 8, vSpacing: 8, rowAlignment: .center) {
                    ForEach(tokens, id: \.self) { token in
                        Token(text: token) {
                            tokens.removeAll { $0 == token }
                        }
                    }
                }
            }
            
            // Input field
            HStack {
                TextField(placeholder, text: $inputText)
                    .focused($isFocused)
                    .onSubmit {
                        addToken()
                    }
                
                if !inputText.isEmpty {
                    Button("Add") {
                        addToken()
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isFocused = false
                    }
                }
            }
        }
    }
    
    private func addToken() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !tokens.contains(trimmed) {
            tokens.append(trimmed)
            inputText = ""
        }
    }
}
