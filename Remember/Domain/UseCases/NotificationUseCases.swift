// Domain/UseCases/NotificationUseCases.swift
import Foundation

// Bildirimleri getir
final class FetchNotificationsUseCase {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func execute(for userId: String) async throws -> [AppNotification] {
        try await repository.fetchNotifications(for: userId)
    }
}

// Okunmamış bildirim sayısını getir
final class GetUnreadNotificationCountUseCase {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func execute(for userId: String) async throws -> Int {
        try await repository.getUnreadCount(for: userId)
    }
}

// Bildirimi okundu olarak işaretle
final class MarkNotificationAsReadUseCase {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func execute(notificationId: String) async throws {
        try await repository.markAsRead(notificationId: notificationId)
    }
}

// Tüm bildirimleri okundu olarak işaretle
final class MarkAllNotificationsAsReadUseCase {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func execute(for userId: String) async throws {
        try await repository.markAllAsRead(for: userId)
    }
}

// Push token'ı kaydet
final class RegisterDeviceTokenUseCase {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func execute(token: String, for userId: String) async throws {
        try await repository.registerDeviceToken(token, for: userId)
    }
}

// Bildirim ayarlarını güncelle
final class UpdateNotificationSettingsUseCase {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func execute(settings: NotificationSettings, for userId: String) async throws {
        try await repository.updateNotificationSettings(settings: settings, for: userId)
    }
}

// Bildirim ayarlarını getir
final class GetNotificationSettingsUseCase {
    private let repository: NotificationRepository

    init(repository: NotificationRepository) {
        self.repository = repository
    }

    func execute(for userId: String) async throws -> NotificationSettings {
        try await repository.getNotificationSettings(for: userId)
    }
}