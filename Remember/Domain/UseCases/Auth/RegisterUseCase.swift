// RegisterUseCase.swift
import Foundation

final class RegisterUseCase {
    private let repository: AuthRepository
    init(repository: AuthRepository) { self.repository = repository }

    func execute(name: String, password: String, confirm: String, token: String) async throws -> User {
        guard !name.isEmpty else {
            throw AppError.emptyField
        }
        guard password == confirm else {
            throw AppError.errorCode
        }
        guard password.count >= 6 else {
            throw AppError.shortCode
        }
        return try await repository.register(name: name, password: password, token: token)
    }
}
