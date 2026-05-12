// Kimlik doğrulama jetonlarını iOS anahtar zincirinde güvenle saklar.
//
// Kayıt/girişte sunucu iki jeton verir:
//   - access_token   → kısa ömürlü JWT, `Authorization: Bearer …` olarak gider
//   - refresh_token  → uzun ömürlü; `POST /api/v1/auth/refresh` ile yenilenir
//
// OTP akışında verify-otp yanıtı yalnızca `temp_token` döner; bu jeton yalnızca `POST /api/v1/auth/register` için kullanılır.
// Erişim jetonu ile karışmaması için ayrı yuvada tutulur.
import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let accessTokenKey  = "yatla.auth.access_token"
    private let refreshTokenKey = "yatla.auth.refresh_token"
    private let tempTokenKey    = "yatla.auth.temp_token"

    // MARK: - Erişim jetonu

    func saveToken(_ token: String) { save(token, for: accessTokenKey) }
    func getToken() -> String? { read(for: accessTokenKey) }
    func deleteToken() { delete(for: accessTokenKey) }

    // MARK: - Yenileme jetonu

    func saveRefreshToken(_ token: String) { save(token, for: refreshTokenKey) }
    func getRefreshToken() -> String? { read(for: refreshTokenKey) }
    func deleteRefreshToken() { delete(for: refreshTokenKey) }

    // MARK: - Geçici jeton (OTP doğrulama → kayıt)

    func saveTempToken(_ token: String) { save(token, for: tempTokenKey) }
    func getTempToken() -> String? { read(for: tempTokenKey) }
    func deleteTempToken() { delete(for: tempTokenKey) }

    // MARK: - Kolaylıklar

    /// Wipes every auth-related token. Call from `logout()` or on 401 cascade.
    func clearAll() {
        deleteToken()
        deleteRefreshToken()
        deleteTempToken()
    }

    var isLoggedIn: Bool {
        getToken() != nil
    }

    // MARK: - Özel yardımcılar

    private func save(_ value: String, for account: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func read(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(for account: String) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
