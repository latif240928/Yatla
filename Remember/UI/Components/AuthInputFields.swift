// UI/Common/Components/AuthInputFields.swift
import SwiftUI

// MARK: - Auth Text Field
struct AuthTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            TextField(placeholder, text: $text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppColors.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isFocused ? AppColors.primary : AppColors.divider,
                            lineWidth: isFocused ? 1.5 : 1
                        )
                )
                .focused($isFocused)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

// MARK: - Auth Secure Field
struct AuthSecureField: View {
    let label: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var placeholder: String = ""
    var errorMessage: String? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            HStack {
                if isVisible {
                    TextField(placeholder, text: $text)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                }

                Button(action: { isVisible.toggle() }) {
                    Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(AppColors.textSecondary)
                        .font(.system(size: 18))
                }
            }
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

            if let error = errorMessage {
                Text(error)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.error)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: errorMessage != nil)
    }
}
