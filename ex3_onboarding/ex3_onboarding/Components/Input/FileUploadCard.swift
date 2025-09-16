//
//  FileUploadCard.swift
//  ex3_onboarding
//
//  Created by Brian Tinsley on 9/11/25.
//

import SwiftUI

struct FileUploadCard: View {
    @Binding var isUploaded: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Simulate file upload - in real app, this would open file picker
            withAnimation(.easeOut(duration: 0.3)) {
                isUploaded.toggle()
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: isUploaded ? "checkmark.circle.fill" : "doc.badge.plus")
                    .font(.system(size: 24))
                    .foregroundColor(isUploaded ? .green : .blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isUploaded ? "LinkedIn/Resume uploaded" : "Upload LinkedIn or Resume")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("You can do this later")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isUploaded {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isUploaded ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.1), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
