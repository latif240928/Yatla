// SendOTPUseCase.swift
import Foundation

final class SendOTPUseCase {
    private let repository: AuthRepository
    init(repository: AuthRepository) { self.repository = repository }

    func execute(phone: String) async throws {
        guard phone.count >= 8 else {
            throw AppError.invalidPhone
        }
        try await repository.sendOTP(phone: phone)
    }
}
