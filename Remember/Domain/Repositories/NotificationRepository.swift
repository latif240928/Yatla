// Domain/Repositories/NotificationRepository.swift
import Foundation

protocol NotificationRepository {
    // Bildirimleri getir
    func fetchNotifications(for userId: String) async throws -> [AppNotification]

    // Okunmamış bildirim sayısını getir
    func getUnreadCount(for userId: String) async throws -> Int

    // Bildirimi okundu olarak işaretle
    func markAsRead(notificationId: String) async throws

    // Tüm bildirimleri okundu olarak işaretle
    func markAllAsRead(for userId: String) async throws

    // Push token'ı kaydet
    func registerDeviceToken(_ token: String, for userId: String) async throws

    // Bildirim ayarlarını güncelle
    func updateNotificationSettings(settings: NotificationSettings, for userId: String) async throws

    // Bildirim ayarlarını getir
    func getNotificationSettings(for userId: String) async throws -> NotificationSettings
}

struct NotificationSettings: Codable {
    var taskAssigned: Bool = true
    var taskStatusChanged: Bool = true
    var taskComments: Bool = true
    var taskFiles: Bool = true
    var taskReminders: Bool = true
    var offers: Bool = true
    var chatMessages: Bool = true
}