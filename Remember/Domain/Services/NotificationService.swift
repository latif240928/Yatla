// Domain/Services/NotificationService.swift
import Foundation
import UserNotifications

protocol NotificationService {
    // Local notification izinlerini iste
    func requestAuthorization() async throws -> Bool

    // Local notification zamanla
    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        triggerDate: Date,
        userInfo: [String: Any]?
    ) async throws

    // Notification'ı iptal et
    func cancelNotification(id: String) async

    // Tüm notification'ları iptal et
    func cancelAllNotifications() async

    // Görev hatırlatması zamanla
    func scheduleTaskReminder(taskId: String, taskTitle: String, dueDate: Date) async throws

    // Görev hatırlatmasını iptal et
    func cancelTaskReminder(taskId: String) async
}

extension NotificationService {
    func scheduleTaskReminder(taskId: String, taskTitle: String, dueDate: Date) async throws {
        let reminderDate = dueDate.addingTimeInterval(-24 * 60 * 60) // 24 saat önce
        guard reminderDate > Date() else { return } // Geçmiş tarih değilse

        try await scheduleNotification(
            id: "task_reminder_\(taskId)",
            title: "Görev Hatırlatması",
            body: "'\(taskTitle)' görevi yarın bitecek",
            triggerDate: reminderDate,
            userInfo: ["taskId": taskId, "type": "task_reminder"]
        )
    }

    func cancelTaskReminder(taskId: String) async {
        await cancelNotification(id: "task_reminder_\(taskId)")
    }
}