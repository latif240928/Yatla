//
//  SignInUseCase.swift
//  Remember
//
//  Created by Latif on 12.04.2026.
//

protocol SignInUseCase {
    func execute(username: String, password: String) async throws -> String
}

final class DefaultSignInUseCase: SignInUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(username: String, password: String) async throws -> String {
        let user = try await repository.login(phone: username, password: password)
        return user.id
    }
}
