import SwiftUI
import Combine

@MainActor
final class SignInViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showPassword: Bool = false

    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }

    var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var passwordTooShort: Bool {
        !password.isEmpty && password.count < 6
    }

    func signIn(router: AppRouter) async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil

        do {
            let user = try await loginUseCase.execute(phone: username, password: password)
            // JWT `AuthRepositoryAPI.login` ile Keychain'e yazılıyor; kullanıcı id'sini token sanma.
            router.completeAuthenticatedSession(user: user)
        } catch {
            errorMessage = "Giriş başarısız. Lütfen bilgilerinizi kontrol edin."
        }

        isLoading = false
    }
}
