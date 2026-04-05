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

    let currentUser = CurrentUserProvider.user  

    private let getChatsUC:         GetChatsUseCase
    private let getGroupChatsUC:    GetGroupChatsUseCase
    private let sendMessageUC:      SendMessageUseCase
    private let deleteChatUC:       DeleteChatUseCase
    private let muteUC:             MuteChatUseCase
    private let getDepartmentsUC:   GetDepartmentsUseCase
    private let createDepartmentUC: CreateDepartmentUseCase

    init(
        repository: ChatRepository = MockChatRepository(),
        departmentRepository: DepartmentRepository = MockDepartmentRepository()
    ) {
        self.getChatsUC         = GetChatsUseCase(repository: repository)
        self.getGroupChatsUC    = GetGroupChatsUseCase(repository: repository)
        self.sendMessageUC      = SendMessageUseCase(repository: repository)
        self.deleteChatUC       = DeleteChatUseCase(repository: repository)
        self.muteUC             = MuteChatUseCase(repository: repository)
        self.getDepartmentsUC   = GetDepartmentsUseCase(repository: departmentRepository)
        self.createDepartmentUC = CreateDepartmentUseCase(repository: departmentRepository)
        Task { await loadAll() }
    }

    func loadAll() async {
        chats      = await getChatsUC.execute(for: currentUser.id)
        groupChats = await getGroupChatsUC.execute(for: currentUser.id)
        if let depts = try? await getDepartmentsUC.execute() {
            departments = depts
        }
    }

    // Departmana göre group chat filtrele
    var filteredGroupChats: [GroupChat] {
        guard let dept = selectedDepartment else { return groupChats }
        return groupChats.filter { $0.department.id == dept.id }
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
    }
}
