// UI/Features/Chats/ChatsViewModel.swift
import SwiftUI
import Combine

@MainActor
final class ChatsViewModel: ObservableObject {

    @Published var chats: [Chat] = []
    @Published var groupChats: [GroupChat] = []
    @Published var selectedChat: Chat? = nil
    @Published var selectedGroup: GroupChat? = nil
    @Published var messageText: String = ""
    @Published var selectedDepartment: Department? = nil
    @Published var departments: [Department] = []
    @Published var directoryUsers: [User] = []

    let currentUser = CurrentUserProvider.user

    private let getChatsUC: GetChatsUseCase
    private let getGroupChatsUC: GetGroupChatsUseCase
    private let getMessagesUC: GetChatMessagesUseCase
    private let sendMessageUC: SendMessageUseCase
    private let deleteChatUC: DeleteChatUseCase
    private let muteUC: MuteChatUseCase
    private let markReadUC: MarkChatAsReadUseCase
    private let openChatUC: OpenChatUseCase
    private let getDepartmentsUC: GetDepartmentsUseCase
    private let createDepartmentUC: CreateDepartmentUseCase
    private let getUsersUC: GetUsersUseCase

    init(container: DIContainer? = nil) {
        let container = container ?? DIContainer.shared
        let repository = container.chatRepository
        let departmentRepository = container.departmentRepository
        self.getChatsUC = GetChatsUseCase(repository: repository)
        self.getGroupChatsUC = GetGroupChatsUseCase(repository: repository)
        self.getMessagesUC = GetChatMessagesUseCase(repository: repository)
        self.sendMessageUC = SendMessageUseCase(repository: repository)
        self.deleteChatUC = DeleteChatUseCase(repository: repository)
        self.muteUC = MuteChatUseCase(repository: repository)
        self.markReadUC = MarkChatAsReadUseCase(repository: repository)
        self.openChatUC = OpenChatUseCase(repository: repository)
        self.getDepartmentsUC = GetDepartmentsUseCase(repository: departmentRepository)
        self.createDepartmentUC = CreateDepartmentUseCase(repository: departmentRepository)
        self.getUsersUC = GetUsersUseCase(repository: container.userRepository)
        Task { await loadAll() }
    }

    func loadAll() async {
        chats = await getChatsUC.execute(for: currentUser.id)
        groupChats = await getGroupChatsUC.execute(for: currentUser.id)
        directoryUsers = await getUsersUC.execute()
        if let depts = try? await getDepartmentsUC.execute() {
            departments = depts
        }
    }

    /// "Gruplar" altında gösterilen departmanlar: kişisel ("Şahsy") hariç tutulur.
    var departmentsForGroupDirectory: [Department] {
        departments
            .filter { $0.id != Department.sahsy.id }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func users(in department: Department) -> [User] {
        directoryUsers
            .filter { $0.departmentIds.contains(department.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var filteredGroupChats: [GroupChat] {
        guard let dept = selectedDepartment else { return groupChats }
        return groupChats.filter { $0.department.id == dept.id }
    }

    /// Bu katılımcı için mevcut bir doğrudan sohbet açar veya yeni bir tane oluşturur.
    /// API yapısında `POST /chats/participant/{id}` üzerinden sunucuya gider
    /// ve arka uç kanonik sohbet kimliğini üretir;
    /// yalnızca bellek içi depoya başvurur.
    @discardableResult
    func openOrCreateChat(with user: User) -> String {
        if let existing = chats.first(where: { $0.participant.id == user.id }) {
            return existing.id
        }
        let optimistic = Chat(id: "local-\(user.id)", participant: user, messages: [])
        chats.insert(optimistic, at: 0)
        Task { [weak self] in
            guard let self else { return }
            if let server = await self.openChatUC.execute(participantId: user.id) {
                await MainActor.run {
                    if let i = self.chats.firstIndex(where: { $0.id == optimistic.id }) {
                        self.chats[i] = server
                    }
                }
            }
        }
        return optimistic.id
    }

    /// Bire bir sohbetin tam mesaj geçmişini arka uçtan yükler
    /// (liste uç noktası yalnızca son mesaj önizlemesini gönderir).
    func loadMessages(forChatId chatId: String) async {
        let history = await getMessagesUC.execute(chatId: chatId)
        guard !history.isEmpty else { return }
        if let i = chats.firstIndex(where: { $0.id == chatId }) {
            chats[i].messages = history
            if selectedChat?.id == chatId {
                selectedChat = chats[i]
            }
        }
    }

    /// `loadMessages(forChatId:)` ile aynı, ancak grup sohbeti için.
    func loadMessages(forGroupChatId groupId: String) async {
        let history = await getMessagesUC.execute(groupChatId: groupId)
        guard !history.isEmpty else { return }
        if let i = groupChats.firstIndex(where: { $0.id == groupId }) {
            groupChats[i].messages = history
            if selectedGroup?.id == groupId {
                selectedGroup = groupChats[i]
            }
        }
    }

    /// Arka uca kullanıcının sohbeti açtığını bildir. Sonraki liste
    /// yenilemesinde `unread_count` sıfırlanır.
    func markAsRead(chatId: String) async {
        await markReadUC.execute(chatId: chatId)
        if let i = chats.firstIndex(where: { $0.id == chatId }) {
            chats[i].serverUnreadCount = 0
            chats[i].messages = chats[i].messages.map {
                var copy = $0; copy.isRead = true; return copy
            }
        }
    }

    func sendMessage(to chatId: String) async {
        guard !messageText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let msg = ChatMessage(
            id: UUID().uuidString,
            sender: currentUser,
            text: messageText,
            sentAt: Date()
        )
        await sendMessageUC.execute(chatId: chatId, message: msg)
        messageText = ""
        if let i = chats.firstIndex(where: { $0.id == chatId }) {
            chats[i].messages.append(msg)
        }
        selectedChat = chats.first(where: { $0.id == chatId })
    }

    /// Departman genelinde bir grup sohbetine mesaj gönder. `sendMessage(to:)`
    /// ile aynı yapıdadır ancak `groupChats`'e yazar ve depoya karşı
    /// "gönder ve unut" şeklinde çalışır (grup gönderimi henüz protokolde
    /// yok — yerel yankı yeterlidir).
    func sendGroupMessage(to groupId: String) async {
        let trimmed = messageText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let msg = ChatMessage(
            id: UUID().uuidString,
            sender: currentUser,
            text: trimmed,
            sentAt: Date()
        )
        messageText = ""
        if let i = groupChats.firstIndex(where: { $0.id == groupId }) {
            groupChats[i].messages.append(msg)
        }
    }

    /// Departman için mevcut grup sohbeti kimliğini döner veya departmana
    /// ait tüm kullanıcılarla doldurulmuş yeni bir tane oluşturur.
    @discardableResult
    func openOrCreateGroupChat(for department: Department) -> String {
        if let existing = groupChats.first(where: { $0.department.id == department.id }) {
            return existing.id
        }
        let members = directoryUsers.filter { $0.departmentIds.contains(department.id) }
        let newGroup = GroupChat(
            id: UUID().uuidString,
            department: department,
            members: members,
            messages: []
        )
        groupChats.insert(newGroup, at: 0)
        return newGroup.id
    }

    func deleteChat(id: String) async {
        await deleteChatUC.execute(id: id)
        withAnimation { chats.removeAll { $0.id == id } }
    }

    func toggleMute(chat: Chat) async {
        if chat.isMuted {
            await muteUC.unmute(id: chat.id)
        } else {
            await muteUC.mute(id: chat.id)
        }
        if let i = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[i].isMuted.toggle()
        }
    }

    func createDepartment(name: String) async {
        guard let dept = try? await createDepartmentUC.execute(name: name) else { return }
        departments.append(dept)
    }

    func inviteUser(name: String, phone: String, department: Department) async {
        let newUser = User(
            id: UUID().uuidString,
            name: name,
            phone: phone,
            departmentIds: [department.id]
        )
        let newChat = Chat(id: UUID().uuidString, participant: newUser, messages: [])
        withAnimation { chats.insert(newChat, at: 0) }
        directoryUsers.append(newUser)
    }
}
