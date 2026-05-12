// Domain/Entities/AppNotification.swift
import Foundation

struct AppNotification: Identifiable, Codable, Equatable {
    let id: String
    let type: NotificationType
    let title: String
    let message: String
    let data: NotificationData?
    let isRead: Bool
    let createdAt: Date
    let userId: String

    enum NotificationType: String, Codable {
        case taskAssigned = "task_assigned"
        case taskStatusChanged = "task_status_changed"
        case taskCommentAdded = "task_comment_added"
        case taskFileUploaded = "task_file_uploaded"
        case taskDueSoon = "task_due_soon"
        case taskOverdue = "task_overdue"
        case offerReceived = "offer_received"
        case offerAccepted = "offer_accepted"
        case offerRejected = "offer_rejected"
        case chatMessage = "chat_message"
    }

    struct NotificationData: Codable, Equatable {
        let taskId: String?
        let chatId: String?
        let offerId: String?
        let userId: String?
    }
}