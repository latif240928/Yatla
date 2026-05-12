// Görev teklifi ve kimlik doğrulama yanıtları için DTO'lar.
import Foundation

struct TaskOfferDTO: Codable {
    let id: String
    let fromUser: UserDTO
    let title: String
    let description: String
    let sentAt: Date
    let status: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, status
        case fromUser = "from_user"
        case sentAt = "sent_at"
    }

    func toDomain() -> TaskOffer {
        let offerStatus: TaskOfferStatus
        switch status.lowercased() {
        case "accepted": offerStatus = .accepted
        case "rejected": offerStatus = .rejected
        default: offerStatus = .pending
        }

        return TaskOffer(
            id: id,
            fromUser: fromUser.toDomain(),
            title: title,
            description: description,
            sentAt: sentAt,
            status: offerStatus
        )
    }
}

// MARK: - Kimlik doğrulama DTO'ları (`openapi.json` ile uyumlu)

/// `/auth/register`, `/auth/login`, `/auth/refresh` yanıt gövdesi.
/// Sunucu kullanıcı nesnesi göndermez; oturumu doldurmak için hemen ardından `/users/me` çağrılmalıdır.
struct LoginResponseDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

/// `{ "message": "..." }` şeklinde OTP gönderim yanıtı.
struct SendOTPResponseDTO: Codable {
    let message: String
}

/// `{ "temp_token": "..." }` — OTP doğrulama yanıtı.
/// Bu bir erişim jetonu değildir; yalnızca izleyen `/auth/register` çağrısı için geçerlidir.
struct VerifyOTPResponseDTO: Codable {
    let tempToken: String

    enum CodingKeys: String, CodingKey {
        case tempToken = "temp_token"
    }
}
