// Data/RepositoryImpl/MockSettingsRepository.swift
import Foundation

final class MockSettingsRepository: SettingsRepository {

    private let defaults = UserDefaults.standard

    private enum Key {
        static let isDarkMode   = "settings_isDarkMode"
        static let language     = "settings_language"
        static let profileName  = "profile_name"
        static let profilePhone = "profile_phone"
        static let profilePass  = "profile_password"
    }

    // MARK: - Settings
    func getSettings() -> AppSettings {
        let isDark = defaults.object(forKey: Key.isDarkMode) as? Bool ?? true
        let langRaw = defaults.string(forKey: Key.language) ?? Language.turkmen.rawValue
        let lang = Language(rawValue: langRaw) ?? .turkmen
        return AppSettings(isDarkMode: isDark, selectedLanguage: lang)
    }

    func updateTheme(isDark: Bool) {
        defaults.set(isDark, forKey: Key.isDarkMode)
    }

    func updateLanguage(_ lang: Language) {
        defaults.set(lang.rawValue, forKey: Key.language)
    }

    // MARK: - Profil
    func getProfile() -> Profile {
        Profile(
            name:     defaults.string(forKey: Key.profileName)  ?? "Abdullatif Durdybayew",
            phone:    defaults.string(forKey: Key.profilePhone) ?? "+993 62445524",
            password: defaults.string(forKey: Key.profilePass)  ?? "••••",
            imageURL: nil
        )
    }

    func updateProfile(_ profile: Profile) {
        defaults.set(profile.name,     forKey: Key.profileName)
        defaults.set(profile.phone,    forKey: Key.profilePhone)
        defaults.set(profile.password, forKey: Key.profilePass)
    }

    // MARK: - Stats
    func getStats() -> Stats {
        let calendar = Calendar.current
        var daily: [Date: Int] = [:]
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let normalized = calendar.startOfDay(for: date)
                daily[normalized] = Int.random(in: 1...8)
            }
        }
        return Stats(
            totalTasks:      50,
            completedTasks:  30,
            failedTasks:     10,
            inProgressTasks:  8,
            returnedTasks:    2,
            totalUsers:       5,
            dailyTasks:      daily
        )
    }

    // MARK: - Logout
    func logout() {
        defaults.set(false, forKey: "isLoggedIn")
    }
}
