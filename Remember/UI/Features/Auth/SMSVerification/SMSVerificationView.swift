// UI/Features/Auth/SMSVerification/SMSVerificationView.swift
import SwiftUI

struct SMSVerificationView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel: SMSVerificationViewModel
    @State private var selectedLanguage: String = "TM"
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

    // MARK: - Computed helpers
    private var boxStrokeColor: (Int) -> Color {
        { index in
            let filled = index < viewModel.otpCode.count
            if let error = viewModel.errorMessage, !error.isEmpty {
                return filled ? AppColors.error : AppColors.error.opacity(0.35)
            }
            if viewModel.isCodeComplete {
                return Color.green
            }
            if index == viewModel.otpCode.count {
                return AppColors.primary
            }
            return filled ? AppColors.primary.opacity(0.6) : Color.white.opacity(0.12)
        }
    }

    private var boxScale: (Int) -> CGFloat {
        { index in
            index == viewModel.otpCode.count ? 1.06 : 1.0
        }
    }

    private var digitAt: (Int) -> String {
        { index in
            let chars = Array(viewModel.otpCode)
            return index < chars.count ? String(chars[index]) : ""
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            // Subtle radial glow at top
            RadialGradient(
                gradient: Gradient(colors: [
                    AppColors.primary.opacity(0.12),
                    Color.clear
                ]),
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Language selector
                HStack {
                    Spacer()
                    LanguageMenu(selectedLanguage: $selectedLanguage)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)

                Spacer()

                // Lock icon
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(AppColors.primary.opacity(0.18))
                        .frame(width: 80, height: 80)
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(AppColors.primary)
                }
                .padding(.bottom, 24)

                // Title
                Text("Sms ugradyldy")
                    .font(AppFonts.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Subtitle
                Text("Telefonyňyza gelen 4 sanly kody giriziň")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 36)

                // OTP Boxes
                otpBoxesView
                    .padding(.bottom, 24)

                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.error)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                        .padding(.bottom, 8)
                }

                // Resend
                resendView
                    .padding(.bottom, 12)

                Spacer()

                // Verify button
                Button(action: {
                    viewModel.verifyOTP(router: router)
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        }
                        Text("Tassyklamak")
                            .font(AppFonts.headline.bold())
                            .foregroundColor(viewModel.isCodeComplete ? .white : AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(viewModel.isCodeComplete
                                  ? AppColors.buttonActive
                                  : AppColors.surface)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                viewModel.isCodeComplete
                                    ? Color.clear
                                    : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                }
                .disabled(!viewModel.isCodeComplete || viewModel.isLoading)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isCodeComplete)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                Text("Gizlinlik syyasaty")
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onTapGesture { isInputFocused = true }
        .onAppear { isInputFocused = true }
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
    }

    // MARK: - OTP Boxes
    private var otpBoxesView: some View {
        ZStack {
            // Hidden real TextField — tüm input buradan
            TextField("", text: $viewModel.otpCode)
                .keyboardType(.numberPad)
                .focused($isInputFocused)
                .opacity(0)
                .frame(width: 1, height: 1)
                .onChange(of: viewModel.otpCode) { newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    let limited = String(filtered.prefix(4))
                    if viewModel.otpCode != limited {
                        viewModel.otpCode = limited
                    }
                }

            // Visual 4 boxes
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    otpBox(index: index)
                        .onTapGesture { isInputFocused = true }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    private func otpBox(index: Int) -> some View {
        let digit = digitAt(index)
        let isActive = index == viewModel.otpCode.count && !viewModel.isCodeComplete
        let isFilled = index < viewModel.otpCode.count
        let hasError = !(viewModel.errorMessage?.isEmpty ?? true)
        let isSuccess = viewModel.isCodeComplete && !hasError

        return ZStack {
            // Box background
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(boxStrokeColor(index), lineWidth: isActive || isFilled ? 2 : 1.5)
                )
                .scaleEffect(boxScale(index))
                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: viewModel.otpCode.count)
                .shadow(
                    color: isSuccess
                        ? Color.green.opacity(0.3)
                        : (hasError && isFilled
                            ? AppColors.error.opacity(0.3)
                            : (isActive ? AppColors.primary.opacity(0.25) : .clear)),
                    radius: 8, x: 0, y: 0
                )

            // Digit or cursor
            if digit.isEmpty && isActive {
                // Blinking cursor
                BlinkingCursor()
            } else {
                Text(digit)
                    .font(.system(size: 26, weight: .bold, design: .monospaced))
                    .foregroundColor(
                        isSuccess ? Color.green :
                        (hasError ? AppColors.error : .white)
                    )
                    .transition(
                        .asymmetric(
                            insertion: .scale(scale: 0.4).combined(with: .opacity),
                            removal: .scale(scale: 0.4).combined(with: .opacity)
                        )
                    )
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: digit)
            }

            // Index number at top
            VStack {
                Text("\(index + 1)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(
                        isActive
                            ? AppColors.primary
                            : Color.white.opacity(0.2)
                    )
                    .padding(.top, 6)
                Spacer()
            }
        }
        .frame(width: 72, height: 72)
    }

    // MARK: - Resend View
    private var resendView: some View {
        Group {
            if viewModel.canResend {
                Button(action: { viewModel.resendOTP() }) {
                    Text("Kody täzeden ugratmak")
                        .font(AppFonts.subheadline.bold())
                        .foregroundColor(AppColors.primary)
                }
                .transition(.opacity)
            } else {
                HStack(spacing: 4) {
                    Text("Kody täzeden ugratmak")
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
}

// MARK: - Blinking Cursor
private struct BlinkingCursor: View {
    @State private var visible = true

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AppColors.primary)
            .frame(width: 2.5, height: 30)
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
}
