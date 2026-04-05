//
//  ChatMessage.swift
//  Remember
//
//  Created by Latif on 31.03.2026.
//

// Domain/Entities/ChatMessage.swift
import Foundation

struct ChatMessage: Identifiable {
    let id: String
    let sender: User
    let text: String
    let sentAt: Date
    var isRead: Bool = false
}

struct Chat: Identifiable {
    let id: String
    let participant: User
    var messages: [ChatMessage]
    var isMuted: Bool = false

    var lastMessage: ChatMessage? { messages.last }
    var unreadCount: Int { messages.filter { !$0.isRead }.count }
}

struct GroupChat: Identifiable {
    let id: String
    let department: Department
    var members: [User]
    var messages: [ChatMessage]

    var lastMessage: ChatMessage? { messages.last }
    var unreadCount: Int { messages.filter { !$0.isRead }.count }
}
