// Ayarlar sekmesi: tema, dil, profil özeti ve istatistik önbelleği.
import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    private let repo: SettingsRepository
    private let container: DIContainer

    @Published var settings: AppSettings
    @Published var profile: Profile
    @Published var stats: Stats
    @Published var isSaved: Bool = false

    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true

    init(
        repo: SettingsRepository? = nil,
        container: DIContainer? = nil
    ) {
        let repo = repo ?? MockSettingsRepository()
        let container = container ?? DIContainer.shared
        self.repo      = repo
        self.container = container
        self.settings  = repo.getSettings()
        self.profile   = repo.getProfile()
        self.stats     = repo.getStats()

        // Görünen kimlik, oturumdaki kullanıcı ile uyumlu olsun (soğuk başlatmada ayarlar sekmesi repo ile gelir).
        syncProfileFromSession()
    }

    // MARK: - Profil

    /// `SessionStore`'daki güncel kullanıcıyı `profile` içine yansıtır.
    /// Kalıcı depo `SettingsRepository` olsa da canlı doğruluk kaynağı oturumdur.
    func syncProfileFromSession() {
        let user = container.session.currentUser
        guard !user.id.isEmpty, user.id != "current-user" else {
            // Henüz yer tutucu oturum — repo'daki profili olduğu gibi bırak.
            return
        }
        var snapshot = profile
        snapshot.name = user.name
        snapshot = Profile(
            name: user.name,
            phone: user.phone,
            password: snapshot.password,
            imageURL: snapshot.imageURL,
            departmentIds: user.departmentIds
        )
        profile = snapshot
        repo.updateProfile(snapshot)
    }

    func updateProfile(name: String) {
        profile.name = name
        repo.updateProfile(profile)
        container.session.updateProfile(name: name)
        flashSaved()
    }

    /// Seçilen avatarı yerelde saklar (mock); API hazır olunca yükleme use case'i eklenecek.
    func updateAvatar(localFileURL: URL) {
        profile.imageURL = localFileURL.absoluteString
        repo.updateProfile(profile)
        flashSaved()
        // TODO: UploadAvatarUseCase ile backend yükleme (uç nokta hazır olunca).
    }

    private func flashSaved() {
        isSaved = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isSaved = false
        }
    }

    // MARK: - Ayarlar

    func toggleTheme() {
        settings.isDarkMode.toggle()
        repo.updateTheme(isDark: settings.isDarkMode)
        container.persistTheme(isDark: settings.isDarkMode)
    }

    func selectLanguage(_ lang: Language) {
        settings.selectedLanguage = lang
        repo.updateLanguage(lang)
        container.persistLanguage(lang)
    }

    func refreshStats() {
        stats = repo.getStats()
    }

    func logout(router: AppRouter) {
        router.logout()
        isLoggedIn = false
    }
}
