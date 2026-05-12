// Ağ katmanında oluşan hataların ortak temsili.
import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, data: Data)
    case decodingError(Error)
    case encodingError(Error)
    /// Çalışan yenileme jetonu olmadan 401; yönlendirici girişe almalıdır.
    case unauthorized
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz adres"
        case .invalidResponse:
            return "Sunucudan geçersiz yanıt"
        case let .serverError(statusCode, data):
            let message = String(data: data, encoding: .utf8) ?? "Yanıt gövdesi yok"
            return "Sunucu hatası \(statusCode): \(message)"
        case let .decodingError(error):
            return "Çözümleme hatası: \(error.localizedDescription)"
        case let .encodingError(error):
            return "Kodlama hatası: \(error.localizedDescription)"
        case .unauthorized:
            return "Oturum süresi doldu. Lütfen yeniden giriş yapın."
        case let .unknown(error):
            return error.localizedDescription
        }
    }
}
