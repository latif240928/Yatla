// UI/Features/Auth/Registration/RegistrationView.swift
import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var container: DIContainer
    @State private var selectedLanguage: String = "TM"

    
    @StateObject private var viewModel: RegistrationViewModel

    init() {
        _viewModel = StateObject(wrappedValue:
            RegistrationViewModel(
                sendOTPUseCase: DIContainer.shared.sendOTPUseCase
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

                Text("Registrasiýa")
                    .font(AppFonts.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                VStack(spacing: 20) {
                    Text("Telefon nomer")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 0) {
                        CountryPicker(selectedCountry: $viewModel.selectedCountry)
                            .frame(height: 52)

                        Rectangle()
                            .fill(AppColors.divider)
                            .frame(width: 1, height: 28)

                        TextField("", text: $viewModel.phoneNumber)
                            .font(AppFonts.body)
                            .foregroundColor(.white)
                            .keyboardType(.phonePad)
                            .padding(.horizontal, 12)
                            .frame(height: 52)
                    }
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primary.opacity(0.5), lineWidth: 1)
                    )

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.error)
                    }

                    Button(action: {
                        viewModel.sendOTP(router: router)
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            }
                            Text("Dowam etmek")
                                .font(AppFonts.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(viewModel.isPhoneValid
                                      ? AppColors.buttonActive
                                      : AppColors.buttonDisabled)
                        )
                    }
                    .disabled(!viewModel.isPhoneValid || viewModel.isLoading)

                    Button(action: {
                        router.navigateToSignIn(phoneNumber: viewModel.fullPhoneNumber)
                    }) {
                        Text("Mende akkaunt bar!")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 4)
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

                Text("Gizlinlik syýasaty")
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }
}
