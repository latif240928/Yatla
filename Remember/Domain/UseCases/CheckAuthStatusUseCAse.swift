
//  CheckAuthStatusUseCAse.swift
import Foundation

protocol CheckAuthStatusUseCaseProtocol {
    func execute() -> Bool
}

final class CheckAuthStatusUseCase: CheckAuthStatusUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute() -> Bool {
        return authRepository.isLoggedIn
    }
}
