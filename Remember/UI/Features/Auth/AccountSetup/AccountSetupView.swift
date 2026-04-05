// UI/Features/Auth/AccountSetup/AccountSetupView.swift
import SwiftUI

struct AccountSetupView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: AccountSetupViewModel
    @State private var selectedLanguage: String = "TM"

    // token
    init(token: String = "") {
        _viewModel = StateObject(wrappedValue:
            AccountSetupViewModel(
                token: token,
                registerUseCase: DIContainer.shared.registerUseCase
            )
        )
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    LanguageMenu(selectedLanguage: $selectedLanguage)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Ýatla programmasyna")
                        .font(AppFonts.largeTitle.bold())
                        .foregroundColor(AppColors.textPrimary)
                    Text("hoş geldiňiz")
                        .font(AppFonts.largeTitle.bold())
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

                VStack(spacing: 16) {
                    AuthTextField(
                        label: "Adynyzy girizin",
                        text: $viewModel.username,
                        placeholder: ""
                    )

                    AuthSecureField(
                        label: "Täze kod girizin",
                        text: $viewModel.password,
                        isVisible: $viewModel.showPassword,
                        placeholder: "",
                        errorMessage: viewModel.passwordTooShort ? "Acar soz gysga! (min 6)" : nil
                    )

                    AuthSecureField(
                        label: "Kody tassyklan",
                        text: $viewModel.confirmPassword,
                        isVisible: $viewModel.showConfirmPassword,
                        placeholder: "",
                        errorMessage: viewModel.passwordMismatch ? "Açar sözler deň däl" : nil
                    )

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.error)
                    }

                    Button(action: {
                        viewModel.register(router: router)
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            }
                            Text("Içeri girmek")
                                .font(AppFonts.headline.bold())
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(viewModel.isFormValid
                                      ? AppColors.buttonActive
                                      : AppColors.buttonDisabled)
                        )
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.surface.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)

                Spacer()

                Text("Gizlinlik syyasaty")
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    AccountSetupView(token: "test_token")
        .environmentObject(AppRouter())
}
