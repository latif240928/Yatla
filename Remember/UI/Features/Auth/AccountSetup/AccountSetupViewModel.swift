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
    @Published var passwordStrength: PasswordStrength = .weak

    // ✅ Error states
    @Published var passwordError: String? = nil
    @Published var confirmError: String? = nil

    // ✅ Submit kontrolü
    @Published var didSubmit: Bool = false

    private let token: String
    private let registerUseCase: RegisterUseCase
    private var cancellables = Set<AnyCancellable>()

    init(token: String, registerUseCase: RegisterUseCase) {
        self.token = token
        self.registerUseCase = registerUseCase
        setupLiveValidationAfterSubmit()
    }

    // ✅ Submit sonrası validation
    private func setupLiveValidationAfterSubmit() {

        // PASSWORD → anlık (submit sonrası)
        $password
            .sink { [weak self] value in
                guard let self else { return }
                self.passwordStrength = self.calculatePasswordStrength(value)
                if self.didSubmit {
                    self.validateAll()
                }
            }
            .store(in: &cancellables)

        // ✅ CONFIRM PASSWORD → 3 saniye sonra kontrol
        $confirmPassword
            .debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                if self.didSubmit {
                    self.validateConfirmPassword()
                }
            }
            .store(in: &cancellables)
    }

    // ✅ TÜM VALIDATION
    func validateAll() {

        // PASSWORD
        if password.isEmpty {
            passwordError = nil
        } else if password.count < 8 {
            passwordError = AppError.shortPassword.localizedDescription
        } else if password.rangeOfCharacter(from: .uppercaseLetters) == nil {
            passwordError = "Iň azyndan 1 uly harp bolmaly"
        } else if password.filter({ $0.isNumber }).count < 2 {
            passwordError = "Iň azyndan 2 san bolmaly"
        } else {
            passwordError = nil
        }

        // CONFIRM PASSWORD
        validateConfirmPassword()
    }

    // ✅ CONFIRM PASSWORD (3 saniye + uzunluk kontrolü)
    func validateConfirmPassword() {

        if confirmPassword.isEmpty {
            confirmError = nil
            return
        }

        // ❌ uzunluk eşit değil
        if confirmPassword.count != password.count {
            confirmError = "Parolanyň uzynlygy gabat gelenok"
            return
        }

        // ❌ içerik eşleşmiyor
        if confirmPassword != password {
            confirmError = AppError.errorCode.localizedDescription
            return
        }

        // ✅ doğru
        confirmError = nil
    }

    // ✅ Form geçerli mi?
    var isFormValid: Bool {
        passwordError == nil &&
        confirmError == nil &&
        !username.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty
    }

    // ✅ REGISTER
    func register(router: AppRouter) {

        didSubmit = true
        validateAll()

        // ❌ hata varsa çık
        if passwordError != nil || confirmError != nil || username.isEmpty {
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let user = try await registerUseCase.execute(
                    name: username,
                    password: password,
                    confirm: confirmPassword,
                    token: token
                )

                isLoading = false

                let savedPhone = UserDefaults.standard.string(forKey: "profile_phone") ?? ""
                UserDefaults.standard.set(username, forKey: "profile_name")

                var merged = user
                if merged.phone.isEmpty { merged.phone = savedPhone }

                router.completeAuthenticatedSession(user: merged)

            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    enum PasswordStrength {
        case weak
        case medium
        case strong
        case veryStrong

        var text: String {
            switch self {
            case .weak: return "Gowşak"
            case .medium: return "Orta"
            case .strong: return "Güýçli"
            case .veryStrong: return "Örän güýçli"
            }
        }

        var color: Color {
            switch self {
            case .weak: return .red
            case .medium: return .orange
            case .strong: return .blue
            case .veryStrong: return .green
            }
        }
    }
    
    func calculatePasswordStrength(_ password: String) -> PasswordStrength {
        
        var score = 0
        
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.filter({ $0.isNumber }).count >= 2 { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet.punctuationCharacters) != nil { score += 1 }

        switch score {
        case 0,1: return .weak
        case 2: return .medium
        case 3: return .strong
        default: return .veryStrong
        }
    }
}

