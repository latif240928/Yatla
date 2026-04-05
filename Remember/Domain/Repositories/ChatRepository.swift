// Domain/Repositories/ChatRepository.swift
import Foundation

protocol ChatRepository {
    func getChats(for userId: String) async -> [Chat]
    func getGroupChats(for userId: String) async -> [GroupChat]
    func sendMessage(chatId: String, message: ChatMessage) async
    func deleteChat(id: String) async
    func muteChat(id: String) async
    func unmuteChat(id: String) async
}
