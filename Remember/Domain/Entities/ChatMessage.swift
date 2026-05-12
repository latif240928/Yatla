//
//  ChatMessage.swift
//  Remember
//
//  Oluşturan: Latif — 31.03.2026.
//

// Bire bir ve grup sohbeti için alan modelleri.
//
// Sunucu sohbet listesinde `unread_count` ve son mesaj önizlemesini zaten gönderir;
// bunları özelliklerde tutarak yalnızca özet gereken ekranların tüm geçmişi yüklemesine gerek kalmaz.
//
// `messages` dizisi depolar tarafından gerektiğinde doldurulur: liste `lastMessage` önizlemesiyle çalışır,
// detay ekranı ise mesaj uç noktalarından tam diziyi alır
// (`GET /api/v1/chats/{chat_id}` ve grup mesajları için ilgili yol).
import Foundation

struct ChatMessage: Identifiable, Codable, Sendable {
    let id: String
    let sender: User
    let text: String
    let sentAt: Date
    var isRead: Bool = false
}

struct Chat: Identifiable, Codable, Sendable {
    let id: String
    let participant: User
    var messages: [ChatMessage]
    var isMuted: Bool = false
    /// Sunucudan gelen okunmamış sayısı (`ChatResponse.unread_count`). Tam liste yüklüyse yerelde
    /// `messages.filter { !$0.isRead }.count` ile de türetilebilir.
    var serverUnreadCount: Int = 0

    nonisolated init(id: String,
                     participant: User,
                     messages: [ChatMessage] = [],
                     isMuted: Bool = false,
                     unreadCount: Int = 0) {
        self.id = id
        self.participant = participant
        self.messages = messages
        self.isMuted = isMuted
        self.serverUnreadCount = unreadCount
    }

    var lastMessage: ChatMessage? { messages.last }
    var unreadCount: Int {
        // Tam geçmiş yüklenmediyse sunucu sayısını kullan (liste boşken yerel sayım eksik kalır).
        if messages.isEmpty { return serverUnreadCount }
        return messages.filter { !$0.isRead }.count
    }
}

struct GroupChat: Identifiable, Codable, Sendable {
    let id: String
    let department: Department
    var members: [User]
    var messages: [ChatMessage]
    var serverUnreadCount: Int = 0

    nonisolated init(id: String,
                     department: Department,
                     members: [User] = [],
                     messages: [ChatMessage] = [],
                     unreadCount: Int = 0) {
        self.id = id
        self.department = department
        self.members = members
        self.messages = messages
        self.serverUnreadCount = unreadCount
    }

    var lastMessage: ChatMessage? { messages.last }
    var unreadCount: Int {
        // Birebir sohbetle aynı mantık: liste henüz gelmediyse sunucu sayısı.
        if messages.isEmpty { return serverUnreadCount }
        return messages.filter { !$0.isRead }.count
    }
}
