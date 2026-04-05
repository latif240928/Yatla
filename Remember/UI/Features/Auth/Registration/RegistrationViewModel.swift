// UI/Features/Auth/Registration/RegistrationViewModel.swift
import SwiftUI
import Combine

@MainActor
final class RegistrationViewModel: ObservableObject {

    @Published var phoneNumber: String = ""
    @Published var selectedCountry: Country = Country.all.first!
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let sendOTPUseCase: SendOTPUseCase

    
    init(sendOTPUseCase: SendOTPUseCase) {
        self.sendOTPUseCase = sendOTPUseCase
    }

    var isPhoneValid: Bool {
        phoneNumber.filter(\.isNumber).count >= 8  
    }

    var fullPhoneNumber: String {
        "\(selectedCountry.dialCode)\(phoneNumber)"
    }

    func sendOTP(router: AppRouter) {
        guard isPhoneValid else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await sendOTPUseCase.execute(phone: fullPhoneNumber)
                isLoading = false
                router.navigateToSMS(phoneNumber: fullPhoneNumber)
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
