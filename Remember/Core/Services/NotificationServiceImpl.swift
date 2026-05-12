// Core/Services/NotificationServiceImpl.swift
import Foundation
import UserNotifications

final class NotificationServiceImpl: NotificationService {
    private let notificationCenter = UNUserNotificationCenter.current()

    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try await notificationCenter.requestAuthorization(options: options)
        return granted
    }

    func scheduleNotification(
        id: String,
        title: String,
        body: String,
        triggerDate: Date,
        userInfo: [String: Any]?
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo ?? [:]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        try await notificationCenter.add(request)
    }

    func cancelNotification(id: String) async {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
    }

    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}