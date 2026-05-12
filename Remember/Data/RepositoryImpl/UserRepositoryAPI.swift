// `UserRepository` protokolünün `openapi.json` içindeki `/api/v1/users/...` grubuna eşlemesi. Özet uç noktalar:
//
//   GET    /api/v1/users                       -> [UserResponse]
//   GET    /api/v1/users/search?q=             -> [UserResponse]
//   GET    /api/v1/users/department/{id}       -> [UserResponse]
//   GET    /api/v1/users/me                    -> UserResponse
//   GET    /api/v1/users/me/stats              -> UserTaskStats
//   GET    /api/v1/users/{id}                  -> UserResponse
//   GET    /api/v1/users/{id}/stats            -> UserTaskStats
//   PUT    /api/v1/users/{id}                  -> UserResponse  (UserUpdate)
//   DELETE /api/v1/users/{id}                  -> 200 OK
//
// Protokolde `taskStats(for:)` senkron tutuldu (mevcut arayüz derlensin diye). Async varyantlar
// Task/await kullanan ekranların sunucudan taze istatistik okumasını sağlar.
import Foundation

final class UserRepositoryAPI: UserRepository {
    private let network: NetworkService
    /// Sunucu tarafı istatistiklerin `user_id` anahtarlı önbelleği. Async yardımcılar doldurur;
    /// senkron `taskStats(for:)` şu ana kadar görülen değeri döner böylece her çağrıda async zorunlu olmaz.
    private var statsCache: [String: UserTaskStats] = [:]

    init(network: NetworkService = .shared) {
        self.network = network
    }

    func getUsers() async -> [User] {
        do {
            let dtos: [UserDTO] = try await network.request(path: "/users", method: .get)
            return dtos.map { $0.toDomain() }
        } catch {
            return []
        }
    }

    func fetchUsers(for departmentId: String?) async -> [User] {
        do {
            if let departmentId, !departmentId.isEmpty {
                let dtos: [UserDTO] = try await network.request(
                    path: "/users/department/\(departmentId)",
                    method: .get
                )
                return dtos.map { $0.toDomain() }
            }
            return await getUsers()
        } catch {
            return []
        }
    }

    func searchUsers(query: String) async -> [User] {
        do {
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return await getUsers() }
            let dtos: [UserDTO] = try await network.request(
                path: "/users/search",
                method: .get,
                queryItems: [URLQueryItem(name: "q", value: trimmed)]
            )
            return dtos.map { $0.toDomain() }
        } catch {
            return []
        }
    }

    /// OpenAPI yüzeyinde yöneticinin isteğe bağlı kullanıcı kaydı yok; kullanıcılar `/auth/register` ile oluşur.
    /// Sessizce yok saymak yerine bu kısıtlamayı açıkça fırlatıyoruz.
    func addUser(_ user: User) async throws {
        throw NetworkError.serverError(
            statusCode: 405,
            data: Data("addUser: unsupported by backend; users are created via /auth/register".utf8)
        )
    }

    func deleteUser(id: String) async throws {
        _ = try await network.request(path: "/users/\(id)", method: .delete) as EmptyResponseDTO
    }

    func taskStats(for userId: String) -> UserTaskStats? {
        statsCache[userId]
    }

    // MARK: - Protokol dışı async ekler (API deposu iç kullanımı)

    /// `/users/me` ile oturum kullanıcısını çeker ve `statsCache`'i günceller;
    /// böylece sonrasında senkron `taskStats(for:)` güncel anlık görüntüyü görebilir.
    func currentUser() async throws -> User {
        let dto: UserDTO = try await network.request(path: "/users/me", method: .get)
        return dto.toDomain()
    }

    func currentUserStats() async throws -> UserTaskStats {
        let dto: UserTaskStatsDTO = try await network.request(path: "/users/me/stats", method: .get)
        let stats = dto.toDomain()
        statsCache[stats.userId] = stats
        return stats
    }

    func userStats(for userId: String) async throws -> UserTaskStats {
        let dto: UserTaskStatsDTO = try await network.request(
            path: "/users/\(userId)/stats",
            method: .get
        )
        let stats = dto.toDomain()
        statsCache[stats.userId] = stats
        return stats
    }

    func updateUser(id: String, name: String?, avatarURL: String?) async throws -> User {
        struct UpdateRequest: Encodable {
            let name: String?
            let avatarUrl: String?

            enum CodingKeys: String, CodingKey {
                case name
                case avatarUrl = "avatar_url"
            }
        }
        let dto: UserDTO = try await network.request(
            path: "/users/\(id)",
            method: .put,
            bodyObject: UpdateRequest(name: name, avatarUrl: avatarURL)
        )
        return dto.toDomain()
    }

    func user(byId id: String) async throws -> User {
        let dto: UserDTO = try await network.request(path: "/users/\(id)", method: .get)
        return dto.toDomain()
    }
}
