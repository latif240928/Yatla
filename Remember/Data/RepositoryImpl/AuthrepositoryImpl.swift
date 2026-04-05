// AuthRepositoryImpl.swift
import Foundation

final class AuthRepositoryImpl: AuthRepository {
    private let keychain = KeychainService.shared

    var isLoggedIn: Bool {
        keychain.getToken() != nil
    }

    func sendOTP(phone: String) async throws {
        // Backend tayyn bolanson API cagyrylyar
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // SMS ugradyldy
    }

    func verifyOTP(phone: String, code: String) async throws -> String {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        // Mock: "2817" kody kabul et
        guard code == "2817" else {
            throw AppError.invalidCode
        }
        return "temp_token_\(phone)"
    }

    func register(name: String, password: String, token: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let finalToken = "final_token_\(name)"
        keychain.saveToken(finalToken)
        return User(id: UUID().uuidString, name: name, phone: token)
    }

    func login(phone: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let token = "login_token_\(phone)"
        keychain.saveToken(token)
        return User(id: UUID().uuidString, name: "User", phone: phone)
    }

    func logout() {
        keychain.deleteToken()
    }
}
