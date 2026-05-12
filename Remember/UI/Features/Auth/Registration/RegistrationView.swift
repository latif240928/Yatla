// UI/Features/Auth/Registration/RegistrationView.swift
//
// Telefon numarası girişi — kimlik doğrulama akışının ilk adımı. Tüm düzen
// `AuthScreenScaffold`'a devredilmiştir; böylece dil değiştirme, gradyan
// arka plan, duyarlı form genişliği ve gizlilik alt bilgisi burada diğer
// kimlik doğrulama ekranlarıyla aynı şekilde davranır.
//
// Tüm metinler `L10n.string(.<anahtar>, language: lang)` üzerinden beslenir;
// böylece sağ üst menüdeki dil değişikliği sayfayı anında yeniden çevirir.

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var container: DIContainer
    @Environment(\.layout) private var layout

    @StateObject private var viewModel: RegistrationViewModel
    @FocusState private var isPhoneFocused: Bool

    init() {
        _viewModel = StateObject(wrappedValue:
            RegistrationViewModel(
                sendOTPUseCase: DIContainer.shared.sendOTPUseCase
            )
        )
    }

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        AuthScreenScaffold {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                title
                phoneCard
            }
        }
    }

    // MARK: - Başlık

    private var title: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.string(.registrationTitle, language: lang))
                .font(AppFonts.largeTitle.bold())
                .foregroundColor(AppColors.textPrimary)
            Text(L10n.string(.smsSubtitle, language: lang))
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)
        }
        .padding(.top, AppSpacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Telefon kartı

    private var phoneCard: some View {
        AuthFormSurface {
            VStack(alignment: .leading, spacing: AppSpacing.l) {
                Text(L10n.string(.registrationPhoneLabel, language: lang))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                phoneRow

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.error)
                }

                primaryButton
                haveAccountButton
            }
        }
    }

    // MARK: - Telefon satırı

    private var phoneRow: some View {
        HStack(spacing: 0) {
            CountryPicker(selectedCountry: $viewModel.selectedCountry)
                .frame(height: 52)

            Rectangle()
                .fill(AppColors.divider)
                .frame(width: 1, height: 28)

            TextField("", text: $viewModel.phoneNumber, prompt:
                Text("000 000 000")
                    .foregroundColor(AppColors.textHint)
            )
            .font(AppFonts.body)
            .foregroundColor(AppColors.textPrimary)
            .keyboardType(.phonePad)
            .padding(.horizontal, AppSpacing.m)
            .frame(height: 52)
            .focused($isPhoneFocused)
        }
        .background(AppColors.surfaceLight)
        .clipShape(AppShape.inputShape)
        .overlay(
            AppShape.inputShape
                .stroke(
                    isPhoneFocused ? AppColors.borderFocused : AppColors.divider,
                    lineWidth: isPhoneFocused ? AppShape.Stroke.focused : AppShape.Stroke.regular
                )
        )
        .animation(.easeInOut(duration: 0.18), value: isPhoneFocused)
    }

    // MARK: - Ana eylem düğmesi

    private var primaryButton: some View {
            AuthGradientPrimaryButton(
                title: L10n.string(.registrationContinue, language: lang),
                titleForeground: .white,
                isEnabled: viewModel.isPhoneValid,
                isLoading: viewModel.isLoading,
                showsTrailingArrow: true,
                animation: .easeInOut(duration: 0.18)
            ) {
                isPhoneFocused = false
                viewModel.sendOTP(router: router)
            }
    }

    private var haveAccountButton: some View {
        Button {
            router.navigateToSignIn()
        } label: {
            HStack(spacing: 6) {
                Text(L10n.string(.registrationHaveAccount, language: lang))
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.primary)
                Image(systemName: "arrow.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }
}

#Preview {
    RegistrationView()
        .environmentObject(AppRouter())
        .environmentObject(DIContainer.shared)
}
