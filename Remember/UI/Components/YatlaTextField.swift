// UI/Components/YatlaTextField.swift
import SwiftUI

struct YatlaTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Yokarky etiket
            Text(label)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            // Field
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboardType)
                }
            }
            .font(AppFonts.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        errorMessage != nil
                            ? AppColors.error
                            : (isFocused ? AppColors.primary : AppColors.divider),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            )
            .focused($isFocused)
            .animation(.easeInOut(duration: 0.2), value: isFocused)

            // Hata mesajı
            if let error = errorMessage {
                Text(error)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }
}
