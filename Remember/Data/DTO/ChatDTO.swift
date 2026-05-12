// Sunucu `openapi.json` sohbet şemasına karşılık gelen veri aktarım nesneleri.
//
//   ChatResponse              { id, participant_id, is_muted, last_message?, unread_count }
//   GroupChatResponse         { id, department_id, last_message?, unread_count }
//   ChatMessageResponse       { id, sender_id, text, sent_at, is_read }
//   GroupChatMessageResponse  ChatMessageResponse ile aynı yapı
//
// Eski mock yapıdan fark: liste uç noktaları artık tam geçmiş veya katılımcı
// kullanıcı nesnesi göndermez — yalnızca kimlikler ve son mesaj özeti. Depoların
// yapması gerekenler:
//
//   1. Sohbet listesini çekmek,
//   2. Gerektiğinde katılımcı kullanıcı / departman bilgisini çekmek,
//   3. Detay açıldığında mesaj geçmişini çekmek.
import Foundation

struct ChatMessageDTO: Codable, Sendable {
    let id: String
    let senderId: String
    let text: String
    let sentAt: Date
    let isRead: Bool

    enum CodingKeys: String, CodingKey {
        case id, text
        case senderId = "sender_id"
        case sentAt = "sent_at"
        case isRead = "is_read"
    }

    nonisolated func toDomain(sender: User) -> ChatMessage {
        ChatMessage(id: id, sender: sender, text: text, sentAt: sentAt, isRead: isRead)
    }

    /// Fallback when we don't have a hydrated sender yet.
    nonisolated func toDomainPlaceholder() -> ChatMessage {
        let placeholder = User(id: senderId, name: "", phone: "")
        return ChatMessage(id: id, sender: placeholder, text: text, sentAt: sentAt, isRead: isRead)
    }
}

struct ChatDTO: Codable, Sendable {
    let id: String
    let participantId: String
    let isMuted: Bool
    let lastMessage: ChatMessageDTO?
    let unreadCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case participantId = "participant_id"
        case isMuted = "is_muted"
        case lastMessage = "last_message"
        case unreadCount = "unread_count"
    }

    /// Build the rich domain `Chat`. Caller supplies the participant `User`
    /// (typically looked up against the user repository) and any messages
    /// the UI already has — the list endpoint only ships the last message.
    nonisolated func toDomain(participant: User, messages: [ChatMessage] = []) -> Chat {
        var allMessages = messages
        if let last = lastMessage {
            // Keep at least the last message preview if no history was loaded yet.
            if allMessages.isEmpty {
                allMessages = [last.toDomain(sender: participant.id == last.senderId ? participant : User(id: last.senderId, name: "", phone: ""))]
            }
        }
        return Chat(
            id: id,
            participant: participant,
            messages: allMessages,
            isMuted: isMuted,
            unreadCount: unreadCount ?? 0
        )
    }
}

struct GroupChatDTO: Codable, Sendable {
    let id: String
    let departmentId: String
    let lastMessage: ChatMessageDTO?
    let unreadCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case departmentId = "department_id"
        case lastMessage = "last_message"
        case unreadCount = "unread_count"
    }

    nonisolated func toDomain(department: Department, members: [User] = [], messages: [ChatMessage] = []) -> GroupChat {
        var allMessages = messages
        if let last = lastMessage, allMessages.isEmpty {
            let sender = members.first(where: { $0.id == last.senderId })
                ?? User(id: last.senderId, name: "", phone: "")
            allMessages = [last.toDomain(sender: sender)]
        }
        return GroupChat(
            id: id,
            department: department,
            members: members,
            messages: allMessages,
            unreadCount: unreadCount ?? 0
        )
    }
}
