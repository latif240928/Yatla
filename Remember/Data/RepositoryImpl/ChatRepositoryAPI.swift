// `openapi.json` içindeki `/api/v1/chats…` uç noktalarının gerçek ağ uygulaması:
//
//   GET    /api/v1/chats                              -> [ChatResponse]
//   GET    /api/v1/chats/groups                       -> [GroupChatResponse]
//   GET    /api/v1/chats/groups/department/{id}       -> GroupChatResponse
//   GET    /api/v1/chats/groups/{id}/messages         -> [GroupChatMessageResponse]
//   POST   /api/v1/chats/groups/{id}/messages         -> GroupChatMessageResponse  ({ text })
//   GET    /api/v1/chats/{chat_id}                    -> [ChatMessageResponse]
//   DELETE /api/v1/chats/{chat_id}                    -> 200 OK
//   POST   /api/v1/chats/participant/{participant_id} -> ChatResponse
//   POST   /api/v1/chats/{chat_id}/messages           -> ChatMessageResponse  ({ text })
//   POST   /api/v1/chats/{chat_id}/read               -> 200 OK
//   POST   /api/v1/chats/{chat_id}/mute               -> ChatResponse
//   POST   /api/v1/chats/{chat_id}/unmute             -> ChatResponse
//
// API sade özet döner (katılımcı **yalnızca id**, son mesaj özeti, okunmamış sayısı).
// Mevcut arayüz şeklini korumak için eksik kullanıcı/departman bilgisi başlangıçta
// verilen depolarla tamamlanır. Tam geçmiş `messages(forChatId:)` / `messages(forGroupChatId:)` ile alınır.
import Foundation

final class ChatRepositoryAPI: ChatRepository {

    private let network: NetworkService
    private let userRepository: UserRepositoryAPI
    private let departmentRepository: DepartmentRepository

    init(
        network: NetworkService = .shared,
        userRepository: UserRepositoryAPI,
        departmentRepository: DepartmentRepository
    ) {
        self.network = network
        self.userRepository = userRepository
        self.departmentRepository = departmentRepository
    }

    // MARK: - Liste

    func getChats(for userId: String) async -> [Chat] {
        do {
            let dtos: [ChatDTO] = try await network.request(path: "/chats", method: .get)
            // Resolve participant users in parallel so the chat list isn't blocked
            // serially on N round-trips.
            return await withTaskGroup(of: (Int, Chat).self) { group in
                for (index, dto) in dtos.enumerated() {
                    group.addTask { [userRepository] in
                        let participant = (try? await userRepository.user(byId: dto.participantId))
                            ?? User(id: dto.participantId, name: "", phone: "")
                        return (index, dto.toDomain(participant: participant))
                    }
                }
                var pairs: [(Int, Chat)] = []
                for await pair in group { pairs.append(pair) }
                return pairs.sorted { $0.0 < $1.0 }.map { $0.1 }
            }
        } catch {
            return []
        }
    }

    func getGroupChats(for userId: String) async -> [GroupChat] {
        do {
            let dtos: [GroupChatDTO] = try await network.request(
                path: "/chats/groups",
                method: .get
            )
            // Resolve departments + members in parallel.
            let departments = (try? await departmentRepository.getDepartments()) ?? []
            return await withTaskGroup(of: (Int, GroupChat).self) { group in
                for (index, dto) in dtos.enumerated() {
                    group.addTask { [userRepository] in
                        let dept = departments.first(where: { $0.id == dto.departmentId })
                            ?? Department(id: dto.departmentId, name: "")
                        let members = await userRepository.fetchUsers(for: dto.departmentId)
                        return (index, dto.toDomain(department: dept, members: members))
                    }
                }
                var pairs: [(Int, GroupChat)] = []
                for await pair in group { pairs.append(pair) }
                return pairs.sorted { $0.0 < $1.0 }.map { $0.1 }
            }
        } catch {
            return []
        }
    }

    // MARK: - Geçmiş

    func messages(forChatId chatId: String) async -> [ChatMessage] {
        do {
            let dtos: [ChatMessageDTO] = try await network.request(
                path: "/chats/\(chatId)",
                method: .get
            )
            return await hydrate(messages: dtos)
        } catch {
            return []
        }
    }

    func messages(forGroupChatId groupChatId: String) async -> [ChatMessage] {
        do {
            let dtos: [ChatMessageDTO] = try await network.request(
                path: "/chats/groups/\(groupChatId)/messages",
                method: .get
            )
            return await hydrate(messages: dtos)
        } catch {
            return []
        }
    }

    // MARK: - Değişiklikler

    func sendMessage(chatId: String, message: ChatMessage) async {
        struct Body: Encodable { let text: String }
        _ = try? await network.request(
            path: "/chats/\(chatId)/messages",
            method: .post,
            bodyObject: Body(text: message.text)
        ) as ChatMessageDTO
    }

    func sendGroupMessage(groupChatId: String, text: String, sender: User) async -> ChatMessage? {
        struct Body: Encodable { let text: String }
        do {
            let dto: ChatMessageDTO = try await network.request(
                path: "/chats/groups/\(groupChatId)/messages",
                method: .post,
                bodyObject: Body(text: text)
            )
            return dto.toDomain(sender: sender.id == dto.senderId ? sender : User(id: dto.senderId, name: "", phone: ""))
        } catch {
            return nil
        }
    }

    func markAsRead(chatId: String) async {
        _ = try? await network.request(
            path: "/chats/\(chatId)/read",
            method: .post
        ) as EmptyResponseDTO
    }

    func openChat(withParticipantId participantId: String) async -> Chat? {
        do {
            let dto: ChatDTO = try await network.request(
                path: "/chats/participant/\(participantId)",
                method: .post
            )
            let participant = (try? await userRepository.user(byId: participantId))
                ?? User(id: participantId, name: "", phone: "")
            return dto.toDomain(participant: participant)
        } catch {
            return nil
        }
    }

    func deleteChat(id: String) async {
        _ = try? await network.request(path: "/chats/\(id)", method: .delete) as EmptyResponseDTO
    }

    func muteChat(id: String) async {
        _ = try? await network.request(path: "/chats/\(id)/mute", method: .post) as ChatDTO
    }

    func unmuteChat(id: String) async {
        _ = try? await network.request(path: "/chats/\(id)/unmute", method: .post) as ChatDTO
    }

    // MARK: - Zenginleştirme

    private func hydrate(messages dtos: [ChatMessageDTO]) async -> [ChatMessage] {
        // Avoid duplicate user lookups by collapsing senders to a unique set.
        let uniqueSenderIds = Array(Set(dtos.map { $0.senderId }))
        var userById: [String: User] = [:]
        await withTaskGroup(of: (String, User?).self) { group in
            for senderId in uniqueSenderIds {
                group.addTask { [userRepository] in
                    return (senderId, try? await userRepository.user(byId: senderId))
                }
            }
            for await (id, user) in group {
                if let user { userById[id] = user }
            }
        }
        return dtos.map { dto in
            let sender = userById[dto.senderId] ?? User(id: dto.senderId, name: "", phone: "")
            return dto.toDomain(sender: sender)
        }
    }
}
