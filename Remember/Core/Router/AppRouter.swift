// Uygulama durumu ve kimlik doğrulama içindeki navigasyon yollarını yönetir.
import SwiftUI
import Combine

enum AuthRoute: Hashable {
    case registration
    case sms(phoneNumber: String)
    case accountSetup(token: String)   // ← AccountSetupView için
    case signIn                        // ← Yeni SignInView için
}

enum AppState {
    case splash
    case auth
    case home
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var appState: AppState = .splash
    @Published var authPath: NavigationPath = NavigationPath()

    /// Ağ katmanı 401 döner ve sessiz yenileme başarısız olunca tetiklenir; varsayılan davranış girişe yönlendirmedir.
    @Published var sessionExpiredAt: Date?

    private var sessionExpiredObserver: NSObjectProtocol?

    init() {
        // Geçerli jeton olmadan korumalı ekranda kalınmasın diye oturum süresi bildirimini dinle.
        sessionExpiredObserver = NotificationCenter.default.addObserver(
            forName: .yatlaSessionExpired,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleSessionExpired()
            }
        }
    }

    deinit {
        if let observer = sessionExpiredObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func handleSplashFinished() {
        if KeychainService.shared.isLoggedIn {
            appState = .home
        } else {
            appState = .auth
        }
    }

    func navigateToSMS(phoneNumber: String) {
        authPath.append(AuthRoute.sms(phoneNumber: phoneNumber))
    }

    func navigateToAccountSetup(token: String) {
        authPath.append(AuthRoute.accountSetup(token: token))
    }

    func navigateToSignIn() {
        authPath.append(AuthRoute.signIn)
    }

    /// `AuthRepository` zaten JWT’yi Keychain’e yazdıysa (ör. `login` / `register`) token tekrar yazılmaz.
    func completeAuthenticatedSession(user: User? = nil) {
        if let user {
            DIContainer.shared.session.signIn(user: user)
        }
        authPath = NavigationPath()
        appState = .home
    }

    /// Token’ı açıkça kaydet (ör. eski akışlar, test).
    func handleLoginSuccess(token: String, user: User? = nil) {
        KeychainService.shared.saveToken(token)
        if let user {
            DIContainer.shared.session.signIn(user: user)
        }
        authPath = NavigationPath()
        appState = .home
    }

    func navigateToHome() {
        authPath = NavigationPath()
        appState = .home
    }

    func logout() {
        DIContainer.shared.authRepository.logout()
        DIContainer.shared.session.signOut()
        authPath = NavigationPath()
        appState = .auth
    }

    // MARK: - Oturum süresi

    /// `NetworkService` `yatlaSessionExpired` yayınladığında çağrılır; jetonları temizler ve kimlik akışına döner.
    func handleSessionExpired() {
        // Birden fazla eşzamanlı 401 ile çift yönlendirme olmasın.
        guard appState != .auth else { return }
        sessionExpiredAt = Date()
        KeychainService.shared.clearAll()
        DIContainer.shared.session.signOut()
        authPath = NavigationPath()
        appState = .auth
    }
}
