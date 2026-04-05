// Domain/Repositories/AuthRepository.swift
import Foundation

protocol AuthRepository {
    
    var isLoggedIn: Bool { get }
    
    // Nomer ugrat, SMS gelsin
    func sendOTP(phone: String) async throws
    
    // SMS kody tassyklamak
    func verifyOTP(phone: String, code: String) async throws -> String // token döner
    
    // Ulanyjy ady + parol bilen hasaba almak (register)
    func register(name: String, password: String, token: String) async throws -> User
    
    // Giriş (login)
    func login(phone: String, password: String) async throws -> User
    
    // Çykyş
    func logout()
}
