//  SettingsRepository.swift
protocol SettingsRepository {
    
    func getSettings() -> AppSettings
    
    func updateTheme(isDark: Bool)
    
    func updateLanguage(_ lang: Language)

    func getProfile() -> Profile
    
    func updateProfile(_ profile: Profile)

    func getStats() -> Stats

    func logout()
}
