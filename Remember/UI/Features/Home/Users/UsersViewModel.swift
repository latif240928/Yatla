// Kullanıcılar sekmesi: liste, arama, silme onayı ve görev teklifleri.
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

    /// Silme işlemi için onay beklenen kullanıcı. `.alert(item:)` ile bağlanır.
    @Published var pendingDeletionUser: User? = nil

    private let userRepository: UserRepository
    private let taskRepository: TaskRepository
    private let getUsersUC: GetUsersUseCase
    private let searchUsersUC: SearchUsersUseCase
    private let offerRepository: TaskOfferRepository

    let currentUser = CurrentUserProvider.user

    /// `taskRepository` varsayılan olarak nil verilir ve gövde içinde `DIContainer` üzerinden çözülür.
    /// Varsayılan argümanda doğrudan `DIContainer.shared` kullanılamaz: argüman ifadesi izole bağlamda çalışır,
    /// kapsayıcı ise `@MainActor` ile bağlıdır.
    init(
        userRepository: UserRepository? = nil,
        offerRepository: TaskOfferRepository? = nil,
        taskRepository: TaskRepository? = nil
    ) {
        let userRepository = userRepository ?? MockUserRepository()
        let offerRepository = offerRepository ?? MockTaskOfferRepository.shared
        self.userRepository   = userRepository
        self.offerRepository  = offerRepository
        self.taskRepository   = taskRepository ?? DIContainer.shared.taskRepository
        self.getUsersUC       = GetUsersUseCase(repository: userRepository)
        self.searchUsersUC    = SearchUsersUseCase(repository: userRepository)
        self.selectedDepartment = MockDepartments.all[0]
        Task { await loadUsers() }
        Task { await loadIncomingOffers() }
    }

    // MARK: - Hesaplanmış özellikler
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

    // MARK: - İşlemler
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

    // MARK: - Silme onayı akışı

    /// Kullanıcıyı silmek için onay aşamasına alır; görünüm `pendingDeletionUser`'ı izlemelidir.
    func requestDeleteUser(_ user: User) {
        pendingDeletionUser = user
    }

    /// Kullanıcı silmeyi onayladığında çağrılır — gerçek silme işlemini yapar.
    func confirmDeletePendingUser() {
        guard let user = pendingDeletionUser else { return }
        pendingDeletionUser = nil
        deleteUser(id: user.id)
    }

    /// Silmeden vazgeçildiğinde çağrılır — bekleyen silme isteğini iptal eder.
    func cancelDeletePendingUser() {
        pendingDeletionUser = nil
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

            // Materialise the accepted offer as a real task in the user's
            // task list so it shows up under "Ýumuşlar". Anything not present
            // on `TaskOffer` (department, due date, etc.) is filled with
            // sensible defaults; the backend will eventually persist a richer
            // offer model.
            let now = Date()
            let dept = offer.fromUser.departmentIds.first
                .flatMap { id in departments.first(where: { $0.id == id }) }
            let task = TaskItem(
                id: "from-offer-\(offer.id)",
                title: offer.title.isEmpty ? "Çakylyk" : offer.title,
                description: offer.description,
                status: .waiting,
                department: dept?.name ?? "—",
                departmentId: dept?.id ?? "sahsy",
                assignees: [
                    TaskAssignee(id: UUID().uuidString, user: currentUser, status: .waiting)
                ],
                assigneeIds: [currentUser.id],
                creatorId: offer.fromUser.id,
                createdAt: now,
                startDate: now,
                dueDate: Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now,
                files: [],
                comments: [],
                number: 0
            )
            try? await taskRepository.addTask(task)

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
