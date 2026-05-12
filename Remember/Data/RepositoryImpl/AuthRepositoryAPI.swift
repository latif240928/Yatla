// `AuthRepository` için gerçek ağ uygulaması. `openapi.json` ile belgelenen FastAPI uç noktaları:
//
//   POST /api/v1/auth/send-otp     { phone }                 -> { message }
//   POST /api/v1/auth/verify-otp   { phone, code }           -> { temp_token }
//   POST /api/v1/auth/register     { name, password, temp_token }
//                                                            -> LoginResponse
//   POST /api/v1/auth/login        { phone, password }       -> LoginResponse
//   POST /api/v1/auth/refresh      { refresh_token }         -> LoginResponse
//   GET  /api/v1/users/me                                    -> UserResponse
//
// Notlar:
//   - `LoginResponse` kullanıcı nesnesi **içermez**; başarılı kayıt/girişten sonra `/users/me` ile doldurulur.
//   - `verify-otp` erişim jetonu vermez — kısa ömürlü `temp_token` döner ve yalnızca `/auth/register` için geçerlidir.
//     `saveTempToken` ile özel anahtar zinciri yuvasına yazılır.
import Foundation

final class AuthRepositoryAPI: AuthRepository {
    private let network: NetworkService
    private let keychain: KeychainService

    init(network: NetworkService = .shared, keychain: KeychainService = .shared) {
        self.network = network
        self.keychain = keychain
    }

    var isLoggedIn: Bool {
        keychain.isLoggedIn
    }

    // MARK: - OTP

    func sendOTP(phone: String) async throws {
        struct OTPRequest: Encodable { let phone: String }

        _ = try await network.request(
            path: "/auth/send-otp",
            method: .post,
            bodyObject: OTPRequest(phone: phone),
            requiresAuth: false
        ) as SendOTPResponseDTO
    }

    func verifyOTP(phone: String, code: String) async throws -> String {
        struct VerifyRequest: Encodable {
            let phone: String
            let code: String
        }

        let response: VerifyOTPResponseDTO = try await network.request(
            path: "/auth/verify-otp",
            method: .post,
            bodyObject: VerifyRequest(phone: phone, code: code),
            requiresAuth: false
        )
        // Geçici jetonu sakla; kayıt ekranı ViewModel'e elle iletmeden okuyabilsin.
        keychain.saveTempToken(response.tempToken)
        return response.tempToken
    }

    // MARK: - Kayıt / Giriş

    func register(name: String, password: String, token: String) async throws -> User {
        struct RegisterRequest: Encodable {
            let name: String
            let password: String
            let tempToken: String

            enum CodingKeys: String, CodingKey {
                case name, password
                case tempToken = "temp_token"
            }
        }

        let tokens: LoginResponseDTO = try await network.request(
            path: "/auth/register",
            method: .post,
            bodyObject: RegisterRequest(name: name, password: password, tempToken: token),
            requiresAuth: false
        )
        keychain.updateTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
        keychain.deleteTempToken()
        return try await fetchCurrentUser()
    }

    func login(phone: String, password: String) async throws -> User {
        struct LoginRequest: Encodable {
            let phone: String
            let password: String
        }

        let tokens: LoginResponseDTO = try await network.request(
            path: "/auth/login",
            method: .post,
            bodyObject: LoginRequest(phone: phone, password: password),
            requiresAuth: false
        )
        keychain.updateTokens(access: tokens.accessToken, refresh: tokens.refreshToken)
        return try await fetchCurrentUser()
    }

    func logout() {
        keychain.clearAll()
    }

    // MARK: - Yardımcılar

    /// Yeni erişim jetonu için oturum `User` nesnesini doldurur.
    /// Kaynak: `/users/me` — kayıt/giriş yanıtında kullanıcı satır içi gelmez.
    private func fetchCurrentUser() async throws -> User {
        let dto: UserDTO = try await network.request(path: "/users/me", method: .get)
        return dto.toDomain()
    }
}
