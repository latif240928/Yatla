// `AuthRepository` için bellek içi sahte uygulama. `API_ENV=mock` iken kullanılır;
// arayüz geliştirirken sunucuya ihtiyaç olmadan uçtan uca akış çalışır.
//
// Gerçek ağ karşılığı: `AuthRepositoryAPI`.
//
// Davranış OpenAPI sözleşmesine yakın tutulur:
//   - `verifyOTP` geçici jeton döner (erişim jetonu değil); özel anahtar zinciri yuvasına yazılır (ürün ile aynı).
//   - `register` / `login` sunucunun verdiği erişim + yenileme çiftini taklit eder; `KeychainService.updateTokens`
//     ile saklanır böylece API_ENV ne olursa olsun uygulamanın gördüğü yapı aynı kalır.
import Foundation

final class MockAuthRepository: AuthRepository {

    private let keychain = KeychainService.shared

    var isLoggedIn: Bool { keychain.isLoggedIn }

    func sendOTP(phone: String) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    func verifyOTP(phone: String, code: String) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        // Production: backend rejects bad codes with 422. We accept anything
        // non-empty so QA can drive the flow with whatever they type.
        guard !code.isEmpty else { throw AppError.invalidCode }
        let tempToken = "mock_temp_token_\(phone)"
        keychain.saveTempToken(tempToken)
        return tempToken
    }

    func register(name: String, password: String, token: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        keychain.updateTokens(
            access: "mock_access_\(name)",
            refresh: "mock_refresh_\(name)"
        )
        keychain.deleteTempToken()
        return User(id: UUID().uuidString, name: name, phone: token)
    }

    func login(phone: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        keychain.updateTokens(
            access: "mock_access_\(phone)",
            refresh: "mock_refresh_\(phone)"
        )
        return User(id: UUID().uuidString, name: "Test User", phone: phone)
    }

    func logout() {
        keychain.clearAll()
    }
}
