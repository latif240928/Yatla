// UI/Features/Auth/AccountSetup/AccountSetupView.swift
//
// Son kimlik doğrulama adımı — kullanıcı bir görünen ad + şifre seçer.
// Düzen `AuthScreenScaffold` üzerinden paylaşılır; metinler tamamen
// yerelleştirilmiştir; renkler ve yarıçaplar merkezi tasarım belirteçlerinden gelir.

import SwiftUI

struct AccountSetupView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var container: DIContainer
    @StateObject private var viewModel: AccountSetupViewModel

    init(token: String = "") {
        _viewModel = StateObject(wrappedValue:
            AccountSetupViewModel(
                token: token,
                registerUseCase: DIContainer.shared.registerUseCase
            )
        )
    }

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        AuthScreenScaffold(
            showsBackButton: true,
            onBack: { router.authPath.removeLast() }
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                title
                formCard
            }
        }
    }

    // MARK: - Başlık

    private var title: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.string(.authWelcomeLine1, language: lang))
                .font(AppFonts.largeTitle.bold())
                .foregroundColor(AppColors.textPrimary)
            Text(L10n.string(.authWelcomeLine2, language: lang))
                .font(AppFonts.largeTitle.bold())
                .foregroundColor(AppColors.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AppSpacing.xxl)
    }

    // MARK: - Form

    private var formCard: some View {
        AuthFormSurface {
            VStack(spacing: AppSpacing.l) {
                AuthTextField(
                    label: L10n.string(.authNameLabel, language: lang),
                    text: $viewModel.username,
                    placeholder: L10n.string(.authNamePlaceholder, language: lang)
                )

                AuthSecureField(
                    label: L10n.string(.authNewPasswordLabel, language: lang),
                    text: $viewModel.password,
                    isVisible: $viewModel.showPassword,
                    placeholder: "",
                    errorMessage: localizedPasswordError
                )

                if !viewModel.password.isEmpty {
                    strengthBar
                        .transition(.opacity)
                }

                AuthSecureField(
                    label: L10n.string(.authConfirmPasswordLabel, language: lang),
                    text: $viewModel.confirmPassword,
                    isVisible: $viewModel.showConfirmPassword,
                    placeholder: "",
                    errorMessage: localizedConfirmError
                )

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }

                primaryButton
            }
        }
    }

    // MARK: - Şifre gücü çubuğu

    private var strengthBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < strengthLevel
                              ? viewModel.passwordStrength.color
                              : AppColors.divider)
                        .frame(height: 4)
                }
            }
            Text(localizedStrength)
                .font(AppFonts.caption1)
                .foregroundColor(viewModel.passwordStrength.color)
        }
    }

    // MARK: - Ana eylem düğmesi

    private var primaryButton: some View {
        AuthGradientPrimaryButton(
            title: L10n.string(.signInButton, language: lang),
            isEnabled: viewModel.isFormValid,
            isLoading: viewModel.isLoading
        ) {
            viewModel.register(router: router)
        }
    }

    // MARK: - Yerelleştirme yardımcıları
    //
    // View model hâlâ yalnızca Türkmence dizeler üretir; böylece `Language`
    // hakkında bilgi sahibi olması gerekmez. Etiketlerin dil menüsünü takip
    // etmesi için çeviriyi render zamanında yaparız.

    private var localizedStrength: String {
        switch viewModel.passwordStrength {
        case .weak:       return L10n.string(.authPasswordWeak, language: lang)
        case .medium:     return L10n.string(.authPasswordMedium, language: lang)
        case .strong:     return L10n.string(.authPasswordStrong, language: lang)
        case .veryStrong: return L10n.string(.authPasswordVeryStrong, language: lang)
        }
    }

    private var localizedPasswordError: String? {
        guard let raw = viewModel.passwordError else { return nil }
        // En yakın L10n anahtarına geri eşle — tanınmayan mesajlar için
        // orijinali koru; böylece kullanıcı yine de bir şey görür.
        if raw.contains("uly harp") {
            return L10n.string(.authPasswordMustHaveUpper, language: lang)
        }
        if raw.contains("san") || raw.contains("digit") {
            return L10n.string(.authPasswordMustHaveDigits, language: lang)
        }
        return raw
    }

    private var localizedConfirmError: String? {
        guard let raw = viewModel.confirmError else { return nil }
        if raw.localizedCaseInsensitiveContains("uzynlyk")
            || raw.localizedCaseInsensitiveContains("length") {
            return L10n.string(.authConfirmLengthMismatch, language: lang)
        }
        return L10n.string(.authConfirmDoesNotMatch, language: lang)
    }

    var strengthLevel: Int {
        switch viewModel.passwordStrength {
        case .weak: return 1
        case .medium: return 2
        case .strong: return 3
        case .veryStrong: return 4
        }
    }
}

#Preview {
    AccountSetupView(token: "test_token")
        .environmentObject(AppRouter())
        .environmentObject(DIContainer.shared)
}
