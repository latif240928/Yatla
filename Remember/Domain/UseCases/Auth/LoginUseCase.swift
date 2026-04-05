// LoginUseCase.swift
import Foundation

final class LoginUseCase {
    private let repository: AuthRepository
    init(repository: AuthRepository) { self.repository = repository }

    func execute(phone: String, password: String) async throws -> User {
        guard !phone.isEmpty, !password.isEmpty else {
            throw AppError.emptyField
        }
        return try await repository.login(phone: phone, password: password)
    }
}
