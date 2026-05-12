// Data/RepositoryImpl/APINotificationRepository.swift
import Foundation

final class APINotificationRepository: NotificationRepository {
    private let networkService: NetworkService

    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    func fetchNotifications(for userId: String) async throws -> [AppNotification] {
        // Contract: `{ "notifications": [...], "unread_count": n }`; some stacks return a bare array.
        let data = try await networkService.requestRawData(
            path: "/notifications",
            method: .get,
            queryItems: [URLQueryItem(name: "userId", value: userId)]
        )
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let envelope = try? decoder.decode(NotificationResponseDTO.self, from: data) {
            return envelope.notifications.map { $0.toDomain() }
        }

        let list = try decoder.decode([NotificationDTO].self, from: data)
        return list.map { $0.toDomain() }
    }

    func getUnreadCount(for userId: String) async throws -> Int {
        let response: [String: Int] = try await networkService.request(
            path: "/notifications/unread-count",
            method: .get,
            queryItems: [URLQueryItem(name: "userId", value: userId)]
        )
        return response["count"] ?? 0
    }

    func markAsRead(notificationId: String) async throws {
        _ = try await networkService.request(
            path: "/notifications/\(notificationId)/read",
            method: .patch
        ) as EmptyResponseDTO
    }

    func markAllAsRead(for userId: String) async throws {
        struct MarkAllReadRequest: Encodable {
            let userId: String
        }

        _ = try await networkService.request(
            path: "/notifications/mark-all-read",
            method: .patch,
            bodyObject: MarkAllReadRequest(userId: userId)
        ) as EmptyResponseDTO
    }

    func registerDeviceToken(_ token: String, for userId: String) async throws {
        let body = PushTokenDTO(deviceToken: token, userId: userId)
        _ = try await networkService.request(
            path: "/devices/register",
            method: .post,
            bodyObject: body
        ) as EmptyResponseDTO
    }

    func updateNotificationSettings(settings: NotificationSettings, for userId: String) async throws {
        _ = try await networkService.request(
            path: "/users/\(userId)/notification-settings",
            method: .put,
            bodyObject: settings
        ) as EmptyResponseDTO
    }

    func getNotificationSettings(for userId: String) async throws -> NotificationSettings {
        return try await networkService.request(
            path: "/users/\(userId)/notification-settings",
            method: .get
        )
    }
}