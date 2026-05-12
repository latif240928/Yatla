// Data/DTO/NotificationDTO.swift
import Foundation

struct NotificationDTO: Codable {
    let id: String
    let type: String
    let title: String
    let message: String
    let data: NotificationDataDTO?
    let isRead: Bool
    let createdAt: String
    let userId: String

    struct NotificationDataDTO: Codable {
        let taskId: String?
        let chatId: String?
        let offerId: String?
        let userId: String?
    }

    func toDomain() -> AppNotification {
        let notificationType: AppNotification.NotificationType
        switch type {
        case "task_assigned": notificationType = .taskAssigned
        case "task_status_changed": notificationType = .taskStatusChanged
        case "task_comment_added": notificationType = .taskCommentAdded
        case "task_file_uploaded": notificationType = .taskFileUploaded
        case "task_due_soon": notificationType = .taskDueSoon
        case "task_overdue": notificationType = .taskOverdue
        case "offer_received": notificationType = .offerReceived
        case "offer_accepted": notificationType = .offerAccepted
        case "offer_rejected": notificationType = .offerRejected
        case "chat_message": notificationType = .chatMessage
        default: notificationType = .taskAssigned // fallback
        }

        let domainData: AppNotification.NotificationData?
        if let dtoData = data {
            domainData = AppNotification.NotificationData(
                taskId: dtoData.taskId,
                chatId: dtoData.chatId,
                offerId: dtoData.offerId,
                userId: dtoData.userId
            )
        } else {
            domainData = nil
        }

        return AppNotification(
            id: id,
            type: notificationType,
            title: title,
            message: message,
            data: domainData,
            isRead: isRead,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            userId: userId
        )
    }
}

struct PushTokenDTO: Codable {
    let deviceToken: String
    let deviceType: String
    let userId: String

    init(deviceToken: String, userId: String, deviceType: String = "ios") {
        self.deviceToken = deviceToken
        self.deviceType = deviceType
        self.userId = userId
    }
}

struct NotificationResponseDTO: Codable {
    let notifications: [NotificationDTO]
    let unreadCount: Int
}