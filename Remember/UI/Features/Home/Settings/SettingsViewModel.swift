// UI/Features/Settings/SettingsViewModel.swift
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
        repo: SettingsRepository = MockSettingsRepository(),
        container: DIContainer = DIContainer.shared
    ) {
        self.repo      = repo
        self.container = container
        self.settings  = repo.getSettings()
        self.profile   = repo.getProfile()
        self.stats     = repo.getStats()
    }

    func updateProfile(name: String) {
        profile.name = name
        repo.updateProfile(profile)
        isSaved = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            isSaved = false
        }
    }

    func toggleTheme() {
        settings.isDarkMode.toggle()
        repo.updateTheme(isDark: settings.isDarkMode)
        container.appSettings.isDarkMode = settings.isDarkMode  // ✅ RootView güncellenir
    }

    func selectLanguage(_ lang: Language) {
        settings.selectedLanguage = lang
        repo.updateLanguage(lang)
        container.appSettings.selectedLanguage = lang  // ✅ sync
    }

    func refreshStats() {
        stats = repo.getStats()
    }

    func logout() {
        repo.logout()
        isLoggedIn = false
    }
}
