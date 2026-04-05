// VerifySMSUseCase.swift
import Foundation

protocol VerifySMSUseCaseProtocol {
    func execute(phone: String, code: String) async throws -> String
}

final class VerifySMSUseCase: VerifySMSUseCaseProtocol {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(phone: String, code: String) async throws -> String {
        guard code.count == 4 else {
            throw AppError.invalidCode
        }
        return try await repository.verifyOTP(phone: phone, code: code)
    }
}
