// UI/Features/Auth/AccountSetup/AccountSetupViewModel.swift
import SwiftUI
import Combine

@MainActor
final class AccountSetupViewModel: ObservableObject {

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showPassword: Bool = false
    @Published var showConfirmPassword: Bool = false

    // SMS den gelen token
    private let token: String
    private let registerUseCase: RegisterUseCase

    // DIContainer.shared yok — daşardan inject
    init(token: String, registerUseCase: RegisterUseCase) {
        self.token = token
        self.registerUseCase = registerUseCase
    }

    var isFormValid: Bool {
        !username.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }

    var passwordMismatch: Bool {
        !confirmPassword.isEmpty && password != confirmPassword
    }

    var passwordTooShort: Bool {
        !password.isEmpty && password.count < 6
    }

    func register(router: AppRouter) {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let _ = try await registerUseCase.execute(
                    name: username,
                    password: password,
                    confirm: confirmPassword,
                    token: token              
                )
                isLoading = false
                if let savedToken = KeychainService.shared.getToken() {
                    router.handleLoginSuccess(token: savedToken)
                }
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
