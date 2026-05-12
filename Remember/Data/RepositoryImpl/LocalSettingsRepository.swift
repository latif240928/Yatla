// UserDefaults tabanlı yerel ayarlar deposu.
import Foundation

final class LocalSettingsRepository: SettingsRepository {

    private let defaults = UserDefaults.standard

    private enum Key {
        static let isDarkMode   = "settings_isDarkMode"
        static let language     = "settings_language"
        static let profileName  = "profile_name"
        static let profilePhone = "profile_phone"
        static let profilePass  = "profile_password"
        static let profileImage = "profile_image_url"
        static let profileDepts = "profile_department_ids"
    }

    // MARK: - Ayarlar
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
    //
    // Önce `UserDefaults`'tan okur (yani kayıt akışının kaydettiği değerleri).
    // Önizlemeler ve kimlik doğrulama öncesi arayüzün yine de görüntülenmesi
    // için bir yer tutucu değere düşer — üretim kodu, kullanıcı giriş yaptıktan
    // sonra bunu `updateProfile(...)` ile DEĞİŞTİRMELİDİR.
    func getProfile() -> Profile {
        Profile(
            name:     defaults.string(forKey: Key.profileName)  ?? "Ulanyjy",
            phone:    defaults.string(forKey: Key.profilePhone) ?? "—",
            password: defaults.string(forKey: Key.profilePass)  ?? "••••",
            imageURL: defaults.string(forKey: Key.profileImage),
            departmentIds: defaults.stringArray(forKey: Key.profileDepts) ?? []
        )
    }

    func updateProfile(_ profile: Profile) {
        defaults.set(profile.name,          forKey: Key.profileName)
        defaults.set(profile.phone,         forKey: Key.profilePhone)
        defaults.set(profile.password,      forKey: Key.profilePass)
        defaults.set(profile.imageURL,      forKey: Key.profileImage)
        defaults.set(profile.departmentIds, forKey: Key.profileDepts)
    }

    // MARK: - İstatistikler
    //
    // Gösterge panelinin sahte yapıda her zaman gösterecek bir şeyi olması
    // için belirli ama çeşitli bir başlık istatistikleri anlık görüntüsü oluşturur.
    // Gerçek sayılar sonunda `GET /stats/me` ile sunulacak ve aynı `Stats`
    // yapısına dönüştürülecektir.
    func getStats() -> Stats {
        let calendar = Calendar.current
        let today = Date()

        var daily: [Date: Int] = [:]
        for i in 0..<14 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let normalized = calendar.startOfDay(for: date)
                daily[normalized] = Int.random(in: 1...8)
            }
        }

        // Saat dağılımı — 9-11 ve 14-17 aralıklarını en yoğun dilimler yap.
        var hourly: [Int: Int] = [:]
        for hour in 0..<24 {
            switch hour {
            case 9...11:  hourly[hour] = Int.random(in: 6...10)
            case 14...17: hourly[hour] = Int.random(in: 7...11)
            case 18...20: hourly[hour] = Int.random(in: 2...4)
            case 0...5:   hourly[hour] = 0
            default:      hourly[hour] = Int.random(in: 1...3)
            }
        }

        // Hafta içi dağılımı — Salı/Perşembe en yoğun günler.
        var weekly: [Int: Int] = [:]
        for weekday in 1...7 {
            switch weekday {
            case 3, 5: weekly[weekday] = Int.random(in: 8...12) // Salı, Perşembe
            case 7, 1: weekly[weekday] = Int.random(in: 1...3)  // Cumartesi, Pazar
            default:   weekly[weekday] = Int.random(in: 4...7)
            }
        }

        return Stats(
            totalTasks:        50,
            completedTasks:    30,
            failedTasks:       10,
            inProgressTasks:    8,
            returnedTasks:      2,
            totalUsers:         5,
            dailyTasks:         daily,
            hourlyCompletions:  hourly,
            weekdayCompletions: weekly,
            thisWeekCompleted:  18,
            lastWeekCompleted:  14,
            longPendingTasks:   []
        )
    }

    // MARK: - Çıkış
    func logout() {
        defaults.set(false, forKey: "isLoggedIn")
    }
}
