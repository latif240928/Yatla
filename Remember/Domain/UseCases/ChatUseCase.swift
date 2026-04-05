//  ChatUseCase.swift
import Foundation

final class GetChatsUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(for userId: String) async -> [Chat] {
        await repository.getChats(for: userId)
    }
}

final class GetGroupChatsUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(for userId: String) async -> [GroupChat] {
        await repository.getGroupChats(for: userId)
    }
}

final class SendMessageUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(chatId: String, message: ChatMessage) async {
        await repository.sendMessage(chatId: chatId, message: message)
    }
}

final class DeleteChatUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(id: String) async { await repository.deleteChat(id: id) }
}

final class MuteChatUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func mute(id: String) async { await repository.muteChat(id: id) }
    func unmute(id: String) async { await repository.unmuteChat(id: id) }
}
