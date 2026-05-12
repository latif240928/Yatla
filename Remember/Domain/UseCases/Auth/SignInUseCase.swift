//
//  SignInUseCase.swift
//  Remember
//
//  Created by Latif on 12.04.2026.
//

protocol SignInUseCase {
    func execute(username: String, password: String) async throws -> String
}

// Data/UseCases/Auth/MockSignInUseCase.swift — YENİ DOSYA
final class MockSignInUseCase: SignInUseCase {
    func execute(username: String, password: String) async throws -> String {
        // Backend gelene kadar mock token döndür
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return "mock_token_123"
    }
}
