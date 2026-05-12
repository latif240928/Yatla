//
//  MockChatRepository.swift
//  Remember
//
//  Created by Latif on 31.03.2026.
//

// Data/RepositoryImpl/MockChatRepository.swift
import Foundation

final class MockChatRepository: ChatRepository {

    private let currentUser = User(id: "current-user", name: "Ben", phone: "0500 000 00 00")

    private var chats: [Chat] = [
        Chat(
            id: "c1",
            participant: User(id: "u1", name: "Durdyyewa Çynar", phone: "+993 61000001"),
            messages: [
                ChatMessage(id: "m1", sender: User(id: "u1", name: "Durdyyewa Çynar", phone: ""), text: "Nurgeldi salam, gowmy?", sentAt: Date().addingTimeInterval(-3600), isRead: true),
                ChatMessage(id: "m2", sender: User(id: "current-user", name: "Ben", phone: ""), text: "Salam gowy, gowmy ozun?", sentAt: Date().addingTimeInterval(-3500), isRead: true),
                ChatMessage(id: "m3", sender: User(id: "u1", name: "Durdyyewa Çynar", phone: ""), text: "Dizaýnda nämeler etdiň?", sentAt: Date().addingTimeInterval(-3400), isRead: false),
            ]
        ),
        Chat(
            id: "c2",
            participant: User(id: "u2", name: "John Sina", phone: "+993 61000002"),
            messages: [
                ChatMessage(id: "m4", sender: User(id: "u2", name: "John Sina", phone: ""), text: "UI design taýyn boldymy?", sentAt: Date().addingTimeInterval(-7200), isRead: true),
            ]
        ),
        Chat(
            id: "c3",
            participant: User(id: "u3", name: "Gözel Gözel", phone: "+993 61000003"),
            messages: [
                ChatMessage(id: "m5", sender: User(id: "u3", name: "Gözel Gözel", phone: ""), text: "Logo üçin pikiriň barmy?", sentAt: Date().addingTimeInterval(-10800), isRead: false),
            ]
        ),
    ]

    private var groupChats: [GroupChat] = [
        GroupChat(
            id: "g1",
            department: Department(id: "dept-1", name: "Dowletli Nesibe"),
            members: [
                User(id: "u1", name: "Durdyyewa Çynar", phone: ""),
                User(id: "u2", name: "John Sina", phone: ""),
                User(id: "u3", name: "Gözel Gözel", phone: ""),
                User(id: "u4", name: "Nurgeldi Rejepow", phone: ""),
            ],
            messages: [
                ChatMessage(id: "g1m1", sender: User(id: "u1", name: "Durdyyewa Çynar", phone: ""), text: "Bugün meeting barmy?", sentAt: Date().addingTimeInterval(-1800), isRead: false),
            ]
        ),
        GroupChat(
            id: "g2",
            department: Department(id: "dept-4", name: "Tagma"),
            members: [
                User(id: "u2", name: "John Sina", phone: ""),
                User(id: "u5", name: "Haknazar Haljanow", phone: ""),
            ],
            messages: [
                ChatMessage(id: "g2m1", sender: User(id: "u2", name: "John Sina", phone: ""), text: "Brand logo taýyn!", sentAt: Date().addingTimeInterval(-5400), isRead: true),
            ]
        ),
        GroupChat(
            id: "g3",
            department: Department(id: "dept-3", name: "Juwan media"),
            members: [
                User(id: "u3", name: "Gözel Gözel", phone: ""),
                User(id: "u4", name: "Nurgeldi Rejepow", phone: ""),
                User(id: "u5", name: "Haknazar Haljanow", phone: ""),
                User(id: "u6", name: "Latif", phone: ""),
            ],
            messages: []
        ),
    ]

    func getChats(for userId: String) async -> [Chat] { chats }
    func getGroupChats(for userId: String) async -> [GroupChat] { groupChats }

    func messages(forChatId chatId: String) async -> [ChatMessage] {
        chats.first(where: { $0.id == chatId })?.messages ?? []
    }

    func messages(forGroupChatId groupChatId: String) async -> [ChatMessage] {
        groupChats.first(where: { $0.id == groupChatId })?.messages ?? []
    }

    func sendMessage(chatId: String, message: ChatMessage) async {
        if let i = chats.firstIndex(where: { $0.id == chatId }) {
            chats[i].messages.append(message)
        }
    }

    func sendGroupMessage(groupChatId: String, text: String, sender: User) async -> ChatMessage? {
        let message = ChatMessage(
            id: UUID().uuidString,
            sender: sender,
            text: text,
            sentAt: Date(),
            isRead: false
        )
        if let i = groupChats.firstIndex(where: { $0.id == groupChatId }) {
            groupChats[i].messages.append(message)
        }
        return message
    }

    func markAsRead(chatId: String) async {
        if let i = chats.firstIndex(where: { $0.id == chatId }) {
            chats[i].messages = chats[i].messages.map {
                var copy = $0; copy.isRead = true; return copy
            }
            chats[i].serverUnreadCount = 0
        }
        if let j = groupChats.firstIndex(where: { $0.id == chatId }) {
            groupChats[j].messages = groupChats[j].messages.map {
                var copy = $0; copy.isRead = true; return copy
            }
            groupChats[j].serverUnreadCount = 0
        }
    }

    func openChat(withParticipantId participantId: String) async -> Chat? {
        if let existing = chats.first(where: { $0.participant.id == participantId }) {
            return existing
        }
        let participant = User(id: participantId, name: "Yeni Sohbet", phone: "")
        let chat = Chat(id: "mock-chat-\(participantId)", participant: participant, messages: [])
        chats.append(chat)
        return chat
    }

    func deleteChat(id: String) async {
        chats.removeAll { $0.id == id }
        groupChats.removeAll { $0.id == id }
    }

    func muteChat(id: String) async {
        if let i = chats.firstIndex(where: { $0.id == id }) {
            chats[i].isMuted = true
        }
    }

    func unmuteChat(id: String) async {
        if let i = chats.firstIndex(where: { $0.id == id }) {
            chats[i].isMuted = false
        }
    }
}
