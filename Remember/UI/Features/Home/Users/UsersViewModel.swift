// UI/Features/Users/UsersViewModel.swift
import Foundation
import Combine

@MainActor
final class UsersViewModel: ObservableObject {

    @Published var showDepartmentSheet: Bool = false
    @Published var selectedDepartment: Department   
    @Published var users: [User] = []
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    @Published var incomingOffers: [TaskOffer] = []
    @Published var showAddUserSheet: Bool = false
    @Published var selectedUser: User? = nil
    @Published var showUserDetail: Bool = false
    @Published var departments: [Department] = MockDepartments.all

    private let userRepository: UserRepository
    private let getUsersUC: GetUsersUseCase
    private let searchUsersUC: SearchUsersUseCase
    private let offerRepository: TaskOfferRepository

    let currentUser = CurrentUserProvider.user

    init(
        userRepository: UserRepository = MockUserRepository(),
        offerRepository: TaskOfferRepository = MockTaskOfferRepository.shared
    ) {
        self.userRepository   = userRepository
        self.offerRepository  = offerRepository
        self.getUsersUC       = GetUsersUseCase(repository: userRepository)
        self.searchUsersUC    = SearchUsersUseCase(repository: userRepository)
        self.selectedDepartment = MockDepartments.all[0]  
        Task { await loadUsers() }
        Task { await loadIncomingOffers() }
    }

    // MARK: - Computed
    var filteredUsers: [User] {
        let base: [User]
        if selectedDepartment.id == "all" {
            base = users
        } else {
            base = users.filter {
                $0.departmentIds.contains(selectedDepartment.id)
            }
        }
        guard !searchQuery.isEmpty else { return base }
        return base.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.phone.contains(searchQuery)
        }
    }

    // MARK: - Actions
    func loadUsers() async {
        users = await getUsersUC.execute()
    }

    func selectDepartment(_ dept: Department) {
        selectedDepartment = dept
        Task { await loadUsers() }
    }

    func deleteUser(id: String) {
        Task {
            try? await userRepository.deleteUser(id: id)
            await loadUsers()
        }
    }

    func taskStats(for userId: String) -> UserTaskStats? {
        userRepository.taskStats(for: userId)
    }

    
    func loadIncomingOffers() async {
        incomingOffers = await offerRepository.fetchIncomingOffers(for: currentUser.id)
    }

    func acceptOffer(_ offer: TaskOffer) {
        Task {
            await offerRepository.acceptOffer(id: offer.id)
            await loadIncomingOffers()
        }
    }

    func rejectOffer(_ offer: TaskOffer) {
        Task {
            await offerRepository.rejectOffer(id: offer.id)
            await loadIncomingOffers()
        }
    }

    func inviteUser(name: String, phone: String, department: Department) {
        let offer = TaskOffer(
            id: UUID().uuidString,
            fromUser: currentUser,
            title: "Çakylyk",
            description: "\(name) - \(phone) - \(department.name)",
            sentAt: Date(),
            status: .pending
        )
        Task {
            await offerRepository.sendOffer(offer, to: UUID().uuidString)
        }
    }
}
