// Bağımlılık enjeksiyonu: depolar, servisler ve use case örnekleri tek yerden üretilir.
import Foundation
import Combine

@MainActor
final class DIContainer: ObservableObject {
    static let shared = DIContainer()
    private let settingsDefaults = UserDefaults.standard
    private enum SettingsKey {
        static let isDarkMode = "settings_isDarkMode"
        static let language   = "settings_language"
    }

    @Published var appSettings: AppSettings

    /// Oturumdaki kullanıcı. ViewModel'ler mümkünse bunu kullanır; statik `CurrentUserProvider` yerine tercih edilir.
    /// Kimlik doğrulama akışı günceller.
    let session: SessionStore

    private init() {
        let isDark = settingsDefaults.object(forKey: SettingsKey.isDarkMode) as? Bool ?? true
        let langRaw = settingsDefaults.string(forKey: SettingsKey.language) ?? Language.turkmen.rawValue
        let lang = Language(rawValue: langRaw) ?? .turkmen
        appSettings = AppSettings(isDarkMode: isDark, selectedLanguage: lang)
        session = SessionStore()
    }

    func persistTheme(isDark: Bool) {
        appSettings.isDarkMode = isDark
        settingsDefaults.set(isDark, forKey: SettingsKey.isDarkMode)
    }

    func persistLanguage(_ language: Language) {
        appSettings.selectedLanguage = language
        settingsDefaults.set(language.rawValue, forKey: SettingsKey.language)
    }

    // MARK: - Depolar
    //
    // Seçim: `APIEnvironment.current.isMock` ise bellek içi sahte veri,
    // değilse gerçek API sınıfları kullanılır.
    //
    // Böylece backend hazır olmadan arayüz uçtan uca test edilebilir.
    // Info.plist veya derleme ayarındaki `API_ENV` değişince uygulama gerçek sunucuya bağlanır.
    private let useMocks = APIEnvironment.current.isMock

    lazy var authRepository: AuthRepository = useMocks
        ? MockAuthRepository()
        : AuthRepositoryAPI()

    lazy var departmentRepository: DepartmentRepository = useMocks
        ? MockDepartmentRepository()
        : DepartmentRepositoryAPI()

    lazy var taskRepository: TaskRepository = useMocks
        ? TaskRepositoryImpl(userRepository: userRepository)
        : TaskRepositoryAPI()

    /// Protokol arkasında tutulan somut API deposu; `ChatRepositoryAPI` gibi yerler
    /// `UserRepository` protokolünde olmayan ek async metotlara (`user(byId:)` vb.) buradan erişir.
    lazy var userRepositoryAPI: UserRepositoryAPI = UserRepositoryAPI()

    lazy var userRepository: UserRepository = useMocks
        ? MockUserRepository()
        : userRepositoryAPI

    lazy var chatRepository: ChatRepository = useMocks
        ? MockChatRepository()
        : ChatRepositoryAPI(
            userRepository: userRepositoryAPI,
            departmentRepository: departmentRepository
        )

    lazy var taskOfferRepository: TaskOfferRepository = MockTaskOfferRepository.shared

    // Bildirim deposu her zaman API uygulamasını kullanır. Mock ortamda istek çoğu zaman başarısız olur;
    // çevrimdışı bildirim deneyimi gerekirse ana hedefe `MockNotificationRepository` eklenebilir.
    lazy var notificationRepository: NotificationRepository = APINotificationRepository()
    
    // MARK: - Servisler
    lazy var notificationService: NotificationService = NotificationServiceImpl()
    

    // MARK: - Kimlik doğrulama use case'leri
    lazy var sendOTPUseCase         = SendOTPUseCase(repository: authRepository)
    lazy var verifySMSUseCase       = VerifySMSUseCase(repository: authRepository)
    lazy var registerUseCase        = RegisterUseCase(repository: authRepository)
    lazy var loginUseCase           = LoginUseCase(repository: authRepository)
    lazy var signInUseCase: SignInUseCase = MockSignInUseCase()
    lazy var checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository: authRepository)

    // MARK: - Departman use case'leri
    lazy var getDepartmentsUseCase   = GetDepartmentsUseCase(repository: departmentRepository)
    lazy var createDepartmentUseCase = CreateDepartmentUseCase(repository: departmentRepository)

    // MARK: - Görev use case'leri
    lazy var getTasksUseCase         = GetTasksUseCase(repository: taskRepository)
    lazy var createTaskUseCase       = CreateTaskUseCase(repository: taskRepository)
    lazy var updateTaskStatusUseCase = UpdateTaskStatusUseCase(repository: taskRepository)
    lazy var deleteTaskUseCase       = DeleteTaskUseCase(repository: taskRepository)
    lazy var addAssigneeUseCase      = AddAssigneeUseCase(repository: taskRepository)
    lazy var removeAssigneeUseCase   = RemoveAssigneeUseCase(repository: taskRepository)
    lazy var addCommentUseCase       = AddCommentUseCase(repository: taskRepository)

    // MARK: - Kullanıcı use case'leri
    lazy var getUsersUseCase    = GetUsersUseCase(repository: userRepository)
    lazy var searchUsersUseCase = SearchUsersUseCase(repository: userRepository)

    // MARK: - Sohbet use case'leri
    lazy var getChatsUseCase         = GetChatsUseCase(repository: chatRepository)
    lazy var getGroupChatsUseCase    = GetGroupChatsUseCase(repository: chatRepository)
    lazy var getChatMessagesUseCase  = GetChatMessagesUseCase(repository: chatRepository)
    lazy var sendMessageUseCase      = SendMessageUseCase(repository: chatRepository)
    lazy var deleteChatUseCase       = DeleteChatUseCase(repository: chatRepository)
    lazy var muteChatUseCase         = MuteChatUseCase(repository: chatRepository)
    lazy var markChatAsReadUseCase   = MarkChatAsReadUseCase(repository: chatRepository)
    lazy var openChatUseCase         = OpenChatUseCase(repository: chatRepository)

    // MARK: - Görev teklifi use case'leri
    lazy var fetchTaskOffersUseCase  = FetchTaskOffersUseCase(repo: taskOfferRepository)
    lazy var respondToOfferUseCase   = RespondToOfferUseCase(repo: taskOfferRepository)
    lazy var sendTaskOfferUseCase    = SendTaskOfferUseCase(repo: taskOfferRepository)

    // MARK: - Bildirim use case'leri
    lazy var fetchNotificationsUseCase = FetchNotificationsUseCase(repository: notificationRepository)
    lazy var getUnreadNotificationCountUseCase = GetUnreadNotificationCountUseCase(repository: notificationRepository)
    lazy var markNotificationAsReadUseCase = MarkNotificationAsReadUseCase(repository: notificationRepository)
    lazy var markAllNotificationsAsReadUseCase = MarkAllNotificationsAsReadUseCase(repository: notificationRepository)
    lazy var registerDeviceTokenUseCase = RegisterDeviceTokenUseCase(repository: notificationRepository)
    lazy var updateNotificationSettingsUseCase = UpdateNotificationSettingsUseCase(repository: notificationRepository)
    lazy var getNotificationSettingsUseCase = GetNotificationSettingsUseCase(repository: notificationRepository)
}

extension DIContainer {
    var uploadTaskFileUseCase: UploadTaskFileUseCase {
        UploadTaskFileUseCaseImpl(taskRepository: taskRepository)
    }
}

