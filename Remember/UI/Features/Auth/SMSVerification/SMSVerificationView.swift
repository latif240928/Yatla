// UI/Features/Auth/SMSVerification/SMSVerificationView.swift

import SwiftUI

struct SMSVerificationView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var container: DIContainer
    @StateObject private var viewModel: SMSVerificationViewModel
    @FocusState private var isInputFocused: Bool

    init(phoneNumber: String) {
        _viewModel = StateObject(wrappedValue:
            SMSVerificationViewModel(
                phoneNumber: phoneNumber,
                verifySMSUseCase: DIContainer.shared.verifySMSUseCase,
                sendOTPUseCase: DIContainer.shared.sendOTPUseCase
            )
        )
    }

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        AuthScreenScaffold(
            showsBackButton: true,
            onBack: { router.authPath.removeLast() }
        ) {
            VStack(spacing: AppSpacing.xl) {
                lockBadge
                titleBlock
                otpBoxesView
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.l)
                        .transition(.opacity)
                }
                resendView
                primaryButton
            }
            .padding(.top, AppSpacing.l)
            .frame(maxWidth: .infinity)
        }
        .onTapGesture { isInputFocused = true }
        .onAppear { isInputFocused = true }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
    }

    // MARK: - Üst bölüm parçaları

    private var lockBadge: some View {
        ZStack {
            AppShape.cardShape
                .fill(AppColors.primary.opacity(0.18))
                .frame(width: 76, height: 76)
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(AppColors.primary)
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text(L10n.string(.smsTitle, language: lang))
                .font(AppFonts.largeTitle.bold())
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(L10n.string(.smsSubtitle, language: lang))
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            Text(viewModel.phoneNumber)
                .font(AppFonts.subheadline.bold())
                .foregroundColor(AppColors.primary)
        }
    }

    // MARK: - OTP

    private var otpBoxesView: some View {
        GeometryReader { geo in
            let horizontalInset: CGFloat = 0
            let spacing: CGFloat = 10
            let count = 4
            let usable = max(geo.size.width - horizontalInset * 2 - spacing * CGFloat(count - 1), 0)
            let side = min(max(usable / CGFloat(count), 50), 70)

            ZStack {
                TextField("", text: $viewModel.otpCode)
                    .keyboardType(.numberPad)
                    .focused($isInputFocused)
                    .opacity(0)
                    .frame(width: 1, height: 1)
                    .onChange(of: viewModel.otpCode) { _, newValue in
                        let filtered = newValue.filter { $0.isNumber }
                        let limited = String(filtered.prefix(4))
                        if viewModel.otpCode != limited {
                            viewModel.otpCode = limited
                        }
                    }

                HStack(spacing: spacing) {
                    ForEach(0..<4, id: \.self) { index in
                        otpBox(index: index, side: side)
                            .onTapGesture { isInputFocused = true }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: side + 8)
        }
        .frame(height: 84)
    }

    private func otpBox(index: Int, side: CGFloat) -> some View {
        let digit = digitAt(index)
        let isActive = index == viewModel.otpCode.count && !viewModel.isCodeComplete
        let isFilled = index < viewModel.otpCode.count
        let hasError = !(viewModel.errorMessage?.isEmpty ?? true)
        let isSuccess = viewModel.isCodeComplete && !hasError

        return ZStack {
            AppShape.inputShape
                .fill(AppColors.surface)
                .overlay(
                    AppShape.inputShape
                        .stroke(
                            boxStrokeColor(index),
                            lineWidth: isActive || isFilled ? AppShape.Stroke.focused : AppShape.Stroke.regular
                        )
                )
                .scaleEffect(boxScale(index))
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: viewModel.otpCode.count)
                .shadow(
                    color: isSuccess
                        ? AppColors.success.opacity(0.3)
                        : (hasError && isFilled
                            ? AppColors.error.opacity(0.3)
                            : (isActive ? AppColors.primary.opacity(0.25) : .clear)),
                    radius: 8, x: 0, y: 0
                )

            if digit.isEmpty && isActive {
                BlinkingCursor()
            } else {
                Text(digit)
                    .font(AppFonts.aestetico(size: min(side * 0.4, 28), weight: .bold))
                    .foregroundColor(
                        isSuccess ? AppColors.success :
                        (hasError ? AppColors.error : AppColors.textPrimary)
                    )
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.4).combined(with: .opacity),
                            removal: .scale(scale: 0.4).combined(with: .opacity)
                        )
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: digit)
            }
        }
        .frame(width: side, height: side)
    }

    // MARK: - Yeniden gönder

    private var resendView: some View {
        Group {
            if viewModel.canResend {
                Button(action: { viewModel.resendOTP() }) {
                    Text(L10n.string(.smsResend, language: lang))
                        .font(AppFonts.subheadline.bold())
                        .foregroundColor(AppColors.primary)
                }
                .transition(.opacity)
            } else {
                HStack(spacing: 4) {
                    Text(L10n.string(.smsResendCountdown, language: lang))
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    Text("(\(viewModel.timerText))")
                        .font(AppFonts.subheadline.bold())
                        .foregroundColor(AppColors.primary)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: viewModel.canResend)
    }

    // MARK: - Onay düğmesi

    private var primaryButton: some View {
        AuthGradientPrimaryButton(
            title: L10n.string(.smsConfirm, language: lang),
            titleForeground: viewModel.isCodeComplete ? .white : AppColors.textSecondary,
            isEnabled: viewModel.isCodeComplete,
            isLoading: viewModel.isLoading,
            animation: .spring(response: 0.3, dampingFraction: 0.7)
        ) {
            viewModel.verifyOTP(router: router)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isCodeComplete)
    }

    // MARK: - Yardımcılar

    private func boxStrokeColor(_ index: Int) -> Color {
        let filled = index < viewModel.otpCode.count
        if let error = viewModel.errorMessage, !error.isEmpty {
            return filled ? AppColors.error : AppColors.error.opacity(0.35)
        }
        if viewModel.isCodeComplete {
            return AppColors.success
        }
        if index == viewModel.otpCode.count {
            return AppColors.primary
        }
        return filled ? AppColors.primary.opacity(0.6) : AppColors.divider
    }

    private func boxScale(_ index: Int) -> CGFloat {
        index == viewModel.otpCode.count ? 1.06 : 1.0
    }

    private func digitAt(_ index: Int) -> String {
        let chars = Array(viewModel.otpCode)
        return index < chars.count ? String(chars[index]) : ""
    }
}

private struct BlinkingCursor: View {
    @State private var visible = true

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AppColors.primary)
            .frame(width: 2.5, height: 26)
            .opacity(visible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    visible.toggle()
                }
            }
    }
}

#Preview {
    SMSVerificationView(phoneNumber: "+993 62445524")
        .environmentObject(AppRouter())
        .environmentObject(DIContainer.shared)
}
