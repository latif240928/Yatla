// UI/Common/Components/AuthInputFields.swift
//
// Kimlik doğrulama akışında kullanılan düz ve güvenli metin alanları.
// Her ikisi de yarıçap ve çizgi kalınlıklarını `AppShape`'ten alır,
// böylece uygulamadaki diğer yuvarlatılmış yüzeylerle uyumlu kalır.

import SwiftUI

struct AuthTextField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            TextField(placeholder, text: $text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .keyboardType(keyboard)
                .padding(.horizontal, AppSpacing.l)
                .padding(.vertical, 14)
                .background(AppColors.surface)
                .clipShape(AppShape.inputShape)
                .overlay(
                    AppShape.inputShape
                        .stroke(
                            isFocused ? AppColors.borderFocused : AppColors.divider,
                            lineWidth: isFocused ? AppShape.Stroke.focused : AppShape.Stroke.regular
                        )
                )
                .focused($isFocused)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

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
                        .font(AppFonts.aestetico(size: 18))
                }
            }
            .padding(.horizontal, AppSpacing.l)
            .padding(.vertical, 14)
            .background(AppColors.surface)
            .clipShape(AppShape.inputShape)
            .overlay(
                AppShape.inputShape
                    .stroke(
                        errorMessage != nil
                            ? AppColors.error
                            : (isFocused ? AppColors.borderFocused : AppColors.divider),
                        lineWidth: isFocused || errorMessage != nil
                            ? AppShape.Stroke.focused
                            : AppShape.Stroke.regular
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
