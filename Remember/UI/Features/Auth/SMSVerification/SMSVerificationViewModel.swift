// UI/Features/Auth/SMSVerification/SMSVerificationViewModel.swift
import SwiftUI
import Combine

@MainActor
final class SMSVerificationViewModel: ObservableObject {

    @Published var otpCode: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var remainingSeconds: Int = 120
    @Published var canResend: Bool = false

    let phoneNumber: String
    private var timerTask: Task<Void, Never>?          // ✅ Timer yerine async Task
    private let verifySMSUseCase: VerifySMSUseCase
    private let sendOTPUseCase: SendOTPUseCase

    // ✅ Parametreler dışarıdan — DIContainer.shared yok
    init(
        phoneNumber: String,
        verifySMSUseCase: VerifySMSUseCase,
        sendOTPUseCase: SendOTPUseCase
    ) {
        self.phoneNumber = phoneNumber
        self.verifySMSUseCase = verifySMSUseCase
        self.sendOTPUseCase = sendOTPUseCase
        startTimer()
    }

    var isCodeComplete: Bool { otpCode.count >= 4 }

    var timerText: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    
    func startTimer() {
        remainingSeconds = 120
        canResend = false
        timerTask?.cancel()

        timerTask = Task {
            while remainingSeconds > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Task.isCancelled { return }
                remainingSeconds -= 1
            }
            canResend = true
        }
    }

    func verifyOTP(router: AppRouter) {
        guard isCodeComplete else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let token = try await verifySMSUseCase.execute(
                    phone: phoneNumber,
                    code: otpCode
                )
                isLoading = false
                
                router.navigateToAccountSetup(token: token)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }

    func resendOTP() {
        guard canResend else { return }
        errorMessage = nil
        Task {
            do {
                try await sendOTPUseCase.execute(phone: phoneNumber)
                startTimer()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    deinit {
        timerTask?.cancel()
    }
}
