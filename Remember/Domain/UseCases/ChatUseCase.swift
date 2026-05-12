// Sohbet verisi için use case'ler (liste, mesajlar, gönderme, sessize alma vb.).
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

/// Birebir veya grup sohbetinin tam mesaj geçmişini getirir.
/// `ChatsView` yalnızca özet listeyi yükler; kullanıcı satıra dokunduğunda detay bu use case'i çağırır.
final class GetChatMessagesUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(chatId: String) async -> [ChatMessage] {
        await repository.messages(forChatId: chatId)
    }
    func execute(groupChatId: String) async -> [ChatMessage] {
        await repository.messages(forGroupChatId: groupChatId)
    }
}

final class SendMessageUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(chatId: String, message: ChatMessage) async {
        await repository.sendMessage(chatId: chatId, message: message)
    }
    func executeGroup(groupChatId: String, text: String, sender: User) async -> ChatMessage? {
        await repository.sendGroupMessage(groupChatId: groupChatId, text: text, sender: sender)
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

/// Sohbetteki okunmamış mesajları sunucuda okundu olarak işaretler.
final class MarkChatAsReadUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(chatId: String) async {
        await repository.markAsRead(chatId: chatId)
    }
}

/// Verilen katılımcı ile birebir sohbeti açar; yoksa oluşturur.
final class OpenChatUseCase {
    private let repository: ChatRepository
    init(repository: ChatRepository) { self.repository = repository }
    func execute(participantId: String) async -> Chat? {
        await repository.openChat(withParticipantId: participantId)
    }
}
