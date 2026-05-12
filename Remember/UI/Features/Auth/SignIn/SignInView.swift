// UI/Features/Auth/SignIn/SignInView.swift

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var container: DIContainer
    @StateObject private var viewModel = SignInViewModel(loginUseCase: DIContainer.shared.loginUseCase)

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
        // View model'ın sabit kodlanmış "giriş başarısız" mesajını
        // kullanıcının seçtiği dille senkronize tut.
        .onChange(of: viewModel.errorMessage) { _, newValue in
            guard newValue != nil else { return }
            viewModel.errorMessage = L10n.string(.authLoginFailed, language: lang)
        }
    }

    // MARK: - Başlık

    private var title: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n.string(.signInLine1, language: lang))
                .font(AppFonts.largeTitle.bold())
                .foregroundColor(AppColors.textPrimary)
            Text(L10n.string(.signInLine2, language: lang))
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
                    label: L10n.string(.authSignInName, language: lang),
                    text: $viewModel.username,
                    placeholder: ""
                )

                AuthSecureField(
                    label: L10n.string(.authSignInPassword, language: lang),
                    text: $viewModel.password,
                    isVisible: $viewModel.showPassword,
                    placeholder: "",
                    errorMessage: viewModel.passwordTooShort
                        ? L10n.string(.authSignInPasswordTooShort, language: lang)
                        : nil
                )

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                primaryButton
                noAccountButton
            }
        }
    }

    // MARK: - Ana düğme

    private var primaryButton: some View {
        AuthGradientPrimaryButton(
            title: L10n.string(.signInButton, language: lang),
            isEnabled: viewModel.isFormValid,
            isLoading: viewModel.isLoading
        ) {
            Task { await viewModel.signIn(router: router) }
        }
    }

    private var noAccountButton: some View {
        Button {
            router.authPath.removeLast()
        } label: {
            Text(L10n.string(.signInNoAccount, language: lang))
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.primary)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SignInView()
        .environmentObject(AppRouter())
        .environmentObject(DIContainer.shared)
}
