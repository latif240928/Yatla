//
//  KeychainService.swift
//  Remember
//
//  Created by Latif on 28.03.2026.
//
// Core/Services/KeychainService.swift
import Foundation
import Security

final class KeychainService {
    static let shared = KeychainService()
    private init() {}

    private let tokenKey = "yatla.auth.token"

    // Token y Keychaine yaz
    func saveToken(_ token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)        
    }

    // Token y  oka — bolmasa nil aylar
    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // Akauntdan chykan son token y poz
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    var isLoggedIn: Bool {
        getToken() != nil
    }
}
