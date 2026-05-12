// Ağ katmanı: ortam, istek gönderme, token yenileme ve sağlık kontrolü.
import Foundation

// MARK: - Ortam (APIEnvironment)

/// Hangi backend'e bağlanılacağı. `APIEnvironment.current` ile derleme veya QA ortamında seçilir.
///
/// Mock dışındaki tüm ortamların taban URL'si `/api/v1` ile biter; backend (FastAPI) uç noktaları bu önek altında yayınlar
/// (`openapi.json` içinde yollar `/api/v1/...` ile başlar).
enum APIEnvironment {
    case mock
    /// Mac veya yerel ağ üzerinden düz HTTP. Varsayılan uvicorn adresi.
    /// Farklı makine için Info.plist / build settings içinde `API_BASE_URL` kullanın.
    case local
    case development
    case staging
    case production

    /// Uygulama açılışında bir kez okunur. Info.plist'teki `API_ENV` ile geçersiz kılınır
    /// (ör. "local", "staging"); Xcode'da `INFOPLIST_KEY_API_ENV` ile enjekte edilebilir.
    static let current: APIEnvironment = {
        let raw = (Bundle.main.object(forInfoDictionaryKey: "API_ENV") as? String)?.lowercased() ?? "mock"
        switch raw {
        case "production":          return .production
        case "staging":             return .staging
        case "development", "dev":  return .development
        case "local", "localhost":  return .local
        default:                    return .mock
        }
    }()

    var baseURL: URL {
        // Kaynak kodu değiştirmeden geçici URL (LAN IP, tünel vb.) için Info.plist üzerinden ezme.
        if let override = (Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines),
           !override.isEmpty,
           let url = URL(string: override) {
            return url
        }
        switch self {
        case .mock:        return URL(string: "https://mock.invalid")!
        case .local:       return URL(string: "http://localhost:8000/api/v1")!
        case .development: return URL(string: "https://dev-api.remember.com/api/v1")!
        case .staging:     return URL(string: "https://staging-api.remember.com/api/v1")!
        case .production:  return URL(string: "https://api.remember.com/api/v1")!
        }
    }

    /// Hata ayıklama rozetinde gösterilen kısa etiket.
    var displayName: String {
        switch self {
        case .mock:        return "MOCK"
        case .local:       return "LOCAL"
        case .development: return "DEV"
        case .staging:     return "STAGING"
        case .production:  return "PROD"
        }
    }

    /// Mock modda gerçek ağ çağrısı yapılmaz.
    var isMock: Bool { self == .mock }
}

// MARK: - Boş HTTP yanıtı

/// Gövdesi önemsiz yazma istekleri için (ör. `DELETE …/:id`). Boş veya `null` gövdede JSON çözümlemesini atlar.
struct EmptyResponseDTO: Decodable {}

// MARK: - HTTP metodu

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Token sağlayıcı

/// `NetworkService`'in doğrudan Keychain'e sıkı bağlanmaması için soyutlama (test ve gevşek bağlantı).
/// 401 durumunda sessiz yenileme için hem erişim hem yenileme jetonu gerekir.
protocol AuthTokenProviding: AnyObject {
    func currentToken() -> String?
    func currentRefreshToken() -> String?
    func updateTokens(access: String, refresh: String)
    func clearTokens()
}

extension KeychainService: AuthTokenProviding {
    func currentToken() -> String? { getToken() }
    func currentRefreshToken() -> String? { getRefreshToken() }
    func updateTokens(access: String, refresh: String) {
        saveToken(access)
        saveRefreshToken(refresh)
    }
    func clearTokens() { clearAll() }
}

// MARK: - Oturum süresi bildirimi

extension Notification.Name {
    /// İstek 401 döner ve sessiz token yenilemesi de başarısız olunca gönderilir.
    /// Yönlendirici / arayüz kullanıcıyı giriş ekranına almalıdır.
    static let yatlaSessionExpired = Notification.Name("yatla.session.expired")
}

// MARK: - NetworkService

final class NetworkService {
    static let shared = NetworkService()

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let tokenProvider: AuthTokenProviding

    /// Aynı anda birden fazla 401 geldiğinde yalnızca tek bir `/auth/refresh` çağrısı yapılmasını sağlar.
    ///
    /// Swift 6 katı eşzamanlılıkta async bağlamda kilit kullanımı kısıtlı olduğu için küçük bir actor kullanılır.
    private actor RefreshCoordinator {
        private var ongoing: Task<Bool, Never>?

        func performOrJoin(_ work: @Sendable @escaping () async -> Bool) async -> Bool {
            if let ongoing { return await ongoing.value }
            let task = Task { await work() }
            ongoing = task
            let result = await task.value
            ongoing = nil
            return result
        }
    }
    private let refreshCoordinator = RefreshCoordinator()

    init(
        session: URLSession = .shared,
        baseURL: URL = APIEnvironment.current.baseURL,
        tokenProvider: AuthTokenProviding = KeychainService.shared
    ) {
        self.session = session
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        headers: [String: String] = [:],
        requiresAuth: Bool = true
    ) async throws -> T {
        let data = try await sendRaw(
            path: path,
            method: method,
            queryItems: queryItems,
            body: body,
            headers: headers,
            requiresAuth: requiresAuth
        )

        if T.self == EmptyResponseDTO.self {
            return EmptyResponseDTO() as! T
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }

    /// Ham gövde döner; çağıran esnek çözümleme yapabilir (ör. bildirim zarfı vs dizi).
    func requestRawData(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        headers: [String: String] = [:],
        requiresAuth: Bool = true
    ) async throws -> Data {
        try await sendRaw(
            path: path,
            method: method,
            queryItems: queryItems,
            body: body,
            headers: headers,
            requiresAuth: requiresAuth
        )
    }

    func request<T: Decodable, U: Encodable>(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        bodyObject: U,
        headers: [String: String] = [:],
        requiresAuth: Bool = true
    ) async throws -> T {
        let body: Data
        do {
            body = try encoder.encode(bodyObject)
        } catch {
            throw NetworkError.encodingError(error)
        }
        return try await request(
            path: path,
            method: method,
            queryItems: queryItems,
            body: body,
            headers: headers,
            requiresAuth: requiresAuth
        )
    }

    // MARK: - Tanılama (health check)

    /// Hızlı bağlantı testi sonucu; asla fırlatmaz, böylece arayüz try/catch gerektirmez.
    struct HealthSnapshot {
        let baseURL: URL
        let environment: APIEnvironment
        let reachable: Bool
        let statusCode: Int?
        let latencyMs: Int?
        let errorMessage: String?

        var summary: String {
            if reachable {
                return "OK \(statusCode ?? 200) · \(latencyMs ?? 0) ms"
            }
            return errorMessage ?? "unreachable"
        }
    }

    /// Sunucunun kökündeki `/health` uç noktasını kontrol eder (`/api/v1` altında değil).
    /// Debug rozeti veya QA için yapılandırılmış sunucunun erişilebilir olduğunu doğrular.
    func healthCheck(timeout: TimeInterval = 4) async -> HealthSnapshot {
        let env = APIEnvironment.current
        let configured = baseURL

        // `/health` ana bilgisayar kökündedir; taban URL'den `/api/v1` yolu çıkarılır.
        let healthURL: URL = {
            if var components = URLComponents(url: configured, resolvingAgainstBaseURL: false) {
                components.path = "/health"
                components.queryItems = nil
                if let url = components.url { return url }
            }
            return configured
        }()

        guard env != .mock else {
            return HealthSnapshot(
                baseURL: configured,
                environment: env,
                reachable: false,
                statusCode: nil,
                latencyMs: nil,
                errorMessage: "API_ENV=mock — no network call performed"
            )
        }

        var probe = URLRequest(url: healthURL)
        probe.httpMethod = "GET"
        probe.timeoutInterval = timeout
        probe.setValue("application/json", forHTTPHeaderField: "Accept")

        let started = Date()
        do {
            let (_, response) = try await session.data(for: probe)
            let elapsed = Int(Date().timeIntervalSince(started) * 1000)
            let status = (response as? HTTPURLResponse)?.statusCode
            let ok = (200...299).contains(status ?? 0)
            return HealthSnapshot(
                baseURL: configured,
                environment: env,
                reachable: ok,
                statusCode: status,
                latencyMs: elapsed,
                errorMessage: ok ? nil : "non-2xx response"
            )
        } catch {
            return HealthSnapshot(
                baseURL: configured,
                environment: env,
                reachable: false,
                statusCode: nil,
                latencyMs: nil,
                errorMessage: error.localizedDescription
            )
        }
    }

    // MARK: - İstek gönderimi

    private func sendRaw(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem],
        body: Data?,
        headers: [String: String],
        requiresAuth: Bool,
        allowRefresh: Bool = true
    ) async throws -> Data {
        let request = try makeRequest(
            path: path,
            method: method,
            queryItems: queryItems,
            body: body,
            headers: headers,
            requiresAuth: requiresAuth
        )

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        if httpResponse.statusCode == 401, requiresAuth, allowRefresh {
            // Bir kez sessiz yenileme dene; başarılıysa orijinal isteği tekrarla.
            let refreshed = await refreshAccessTokenIfPossible()
            if refreshed {
                return try await sendRaw(
                    path: path,
                    method: method,
                    queryItems: queryItems,
                    body: body,
                    headers: headers,
                    requiresAuth: requiresAuth,
                    allowRefresh: false
                )
            }
            tokenProvider.clearTokens()
            NotificationCenter.default.post(name: .yatlaSessionExpired, object: nil)
            throw NetworkError.unauthorized
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
        }

        return data
    }

    private func makeRequest(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem],
        body: Data?,
        headers: [String: String],
        requiresAuth: Bool
    ) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        components.path = (components.path + path)
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        if requiresAuth, let token = tokenProvider.currentToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    // MARK: - Token yenileme

    /// Yenileme başarılıysa `true`; bir sonraki istek tekrarlanabilir.
    private func refreshAccessTokenIfPossible() async -> Bool {
        await refreshCoordinator.performOrJoin { [weak self] in
            guard let self else { return false }
            return await self.performRefresh()
        }
    }

    private func performRefresh() async -> Bool {
        guard let refreshToken = tokenProvider.currentRefreshToken() else { return false }

        struct Body: Encodable {
            let refresh_token: String
            let token_type: String
        }
        struct LoginPayload: Decodable {
            let access_token: String
            let refresh_token: String
            let token_type: String?
        }

        do {
            let bodyData = try encoder.encode(Body(refresh_token: refreshToken, token_type: "bearer"))
            let data = try await sendRaw(
                path: "/auth/refresh",
                method: .post,
                queryItems: [],
                body: bodyData,
                headers: [:],
                requiresAuth: false,
                allowRefresh: false
            )
            let payload = try decoder.decode(LoginPayload.self, from: data)
            tokenProvider.updateTokens(access: payload.access_token, refresh: payload.refresh_token)
            return true
        } catch {
            return false
        }
    }
}
