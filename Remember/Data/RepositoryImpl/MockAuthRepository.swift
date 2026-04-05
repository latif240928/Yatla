// MockAuthRepository.swift
import Foundation

/// test uchin yasama (mock) Auth repository
/// Backend tayyn bolanson AuthRepositoryImpl ulanylar
final class MockAuthRepository: AuthRepository {

    var isLoggedIn: Bool {
        KeychainService.shared.getToken() != nil
    }

    func sendOTP(phone: String) async throws {
        // 0.5 sekunt latency bilen dowam eder
        try await Task.sleep(nanoseconds: 500_000_000)
        print(" Mock: SMS kodu gönderildi → \(phone)")
    }

    func verifyOTP(phone: String, code: String) async throws -> String {
        try await Task.sleep(nanoseconds: 500_000_000)
        let tempToken = "mock_temp_token_\(phone)"
        print(" OTP tassyklandy → token: \(tempToken)")
        return tempToken
    }

    func register(name: String, password: String, token: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        let finalToken = "mock_final_token_\(name)"
        KeychainService.shared.saveToken(finalToken)
        let user = User(id: UUID().uuidString, name: name, phone: token)
        print("🎉 Mock: Ulanyjy yatda saklandy → \(user.name)")
        return user
    }

    func login(phone: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 500_000_000)
        let token = "mock_login_token_\(phone)"
        KeychainService.shared.saveToken(token)
        let user = User(id: UUID().uuidString, name: "Test User", phone: phone)
        print(" Mock: Girildi → \(user.name)")
        return user
    }

    func logout() {
        KeychainService.shared.deleteToken()
        print(" Mock: Çykyldy")
    }
}
