// UI/Components/AuthGradientPrimaryButton.swift
//
// Kayıt / Giriş / Hesap kurulumu / SMS doğrulama ekranlarında kullanılan
// paylaşımlı tam genişlik gradyan CTA butonu. Çağıranlar `titleForeground`
// sağlar, böylece SMS kodu tamamlanmadan etiket soluklaştırılabilir.

import SwiftUI

struct AuthGradientPrimaryButton: View {
    let title: String
    /// Örn. kimlik doğrulama formlarında `.white`, SMS kodu henüz
    /// tamamlanmadığında `AppColors.textSecondary`.
    var titleForeground: Color = .white
    var isEnabled: Bool
    var isLoading: Bool = false
    var showsTrailingArrow: Bool = false
    var animation: Animation = .easeInOut(duration: 0.2)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: showsTrailingArrow ? 10 : 8) {
                if isLoading {
                    ProgressView().tint(.white)
                }
                Text(title)
                    .font(AppFonts.headline.bold())
                    .foregroundColor(titleForeground)
                if showsTrailingArrow {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(titleForeground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                AppShape.buttonShape
                    .fill(
                        isEnabled
                            ? AnyShapeStyle(AppColors.messageFromMeGradient)
                            : AnyShapeStyle(AppColors.buttonDisabled)
                    )
            )
            .shadow(
                color: isEnabled ? AppColors.primary.opacity(0.25) : .clear,
                radius: 12,
                y: 6
            )
        }
        .buttonStyle(PressedScaleStyle())
        .disabled(!isEnabled || isLoading)
        .animation(animation, value: isEnabled)
    }
}
