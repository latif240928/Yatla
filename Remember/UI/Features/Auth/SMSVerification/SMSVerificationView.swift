// UI/Features/Auth/SMSVerification/SMSVerificationView.swift
import SwiftUI

struct SMSVerificationView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: SMSVerificationViewModel
    @State private var selectedLanguage: String = "TM"

    
    init(phoneNumber: String) {
        _viewModel = StateObject(wrappedValue:
            SMSVerificationViewModel(
                phoneNumber: phoneNumber,
                verifySMSUseCase: DIContainer.shared.verifySMSUseCase,
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

                Text("Sms ugradyldy")
                    .font(AppFonts.largeTitle.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                VStack(spacing: 20) {
                    Text("Sms kody giriziň")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("", text: $viewModel.otpCode)
                        .font(.system(size: 22, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.primary.opacity(0.5), lineWidth: 1)
                        )
                        .onChange(of: viewModel.otpCode) { newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            viewModel.otpCode = String(filtered.prefix(4)) 
                        }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.error)
                    }

                    Button(action: {
                        viewModel.verifyOTP(router: router)
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            }
                            Text("Tassyklamak")
                                .font(AppFonts.headline.bold())
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(viewModel.isCodeComplete
                                      ? AppColors.buttonActive
                                      : AppColors.buttonDisabled)
                        )
                    }
                    .disabled(!viewModel.isCodeComplete || viewModel.isLoading)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.isCodeComplete)

                    if viewModel.canResend {
                        Button(action: { viewModel.resendOTP() }) {
                            Text("Kody täzeden ugratmak")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.primary)
                        }
                    } else {
                        Text("Kody täzeden ugratmak \(viewModel.timerText)")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
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
    SMSVerificationView(phoneNumber: "+993 62445524")
        .environmentObject(AppRouter())
}
