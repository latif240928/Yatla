// DIContainer.swift
import Foundation
import Combine

@MainActor
final class DIContainer: ObservableObject {
    static let shared = DIContainer()
    private init() {}

    @Published var appSettings = AppSettings(
        isDarkMode: true,
        selectedLanguage: .turkmen
    )

    // MARK: - Repositories
    lazy var authRepository: AuthRepository       = AuthRepositoryImpl()
    lazy var departmentRepository: DepartmentRepository = MockDepartmentRepository()
    lazy var taskRepository: TaskRepository       = TaskRepositoryImpl()
    lazy var userRepository: UserRepository       = MockUserRepository()
    lazy var chatRepository: ChatRepository       = MockChatRepository()
    lazy var taskOfferRepository: TaskOfferRepository = MockTaskOfferRepository.shared
    

    // MARK: - Auth Use Cases
    lazy var sendOTPUseCase         = SendOTPUseCase(repository: authRepository)
    lazy var verifySMSUseCase       = VerifySMSUseCase(repository: authRepository)
    lazy var registerUseCase        = RegisterUseCase(repository: authRepository)
    lazy var loginUseCase           = LoginUseCase(repository: authRepository)
    lazy var checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository: authRepository)

    // MARK: - Department Use Cases
    lazy var getDepartmentsUseCase   = GetDepartmentsUseCase(repository: departmentRepository)
    lazy var createDepartmentUseCase = CreateDepartmentUseCase(repository: departmentRepository)

    // MARK: - Task Use Cases
    lazy var getTasksUseCase         = GetTasksUseCase(repository: taskRepository)
    lazy var createTaskUseCase       = CreateTaskUseCase(repository: taskRepository)
    lazy var updateTaskStatusUseCase = UpdateTaskStatusUseCase(repository: taskRepository)
    lazy var deleteTaskUseCase       = DeleteTaskUseCase(repository: taskRepository)
    lazy var addAssigneeUseCase      = AddAssigneeUseCase(repository: taskRepository)
    lazy var removeAssigneeUseCase   = RemoveAssigneeUseCase(repository: taskRepository)
    lazy var addCommentUseCase       = AddCommentUseCase(repository: taskRepository)

    // MARK: - User Use Cases
    lazy var getUsersUseCase    = GetUsersUseCase(repository: userRepository)
    lazy var searchUsersUseCase = SearchUsersUseCase(repository: userRepository)

    // MARK: - Chat Use Cases
    lazy var getChatsUseCase      = GetChatsUseCase(repository: chatRepository)
    lazy var getGroupChatsUseCase = GetGroupChatsUseCase(repository: chatRepository)
    lazy var sendMessageUseCase   = SendMessageUseCase(repository: chatRepository)
    lazy var deleteChatUseCase    = DeleteChatUseCase(repository: chatRepository)
    lazy var muteChatUseCase      = MuteChatUseCase(repository: chatRepository)

    // MARK: - TaskOffer Use Cases
    lazy var fetchTaskOffersUseCase  = FetchTaskOffersUseCase(repo: taskOfferRepository)
    lazy var respondToOfferUseCase   = RespondToOfferUseCase(repo: taskOfferRepository)
    lazy var sendTaskOfferUseCase    = SendTaskOfferUseCase(repo: taskOfferRepository)
}

extension DIContainer {
    var uploadTaskFileUseCase: UploadTaskFileUseCase {
        UploadTaskFileUseCaseImpl(taskRepository: taskRepository)
    }
}
