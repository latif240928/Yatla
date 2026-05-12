// Merkezi yerelleştirme tablosu (dört dil). Yeni metin eklerken:
//   1. `Key` enum'a bir case ekleyin
//   2. `table` içinde her dil için karşılık verin (`tk` ana kaynak kabul edilir; geri dönüş sırası `lang ?? .turkmen`).
//   3. Görünümdeki düz metni `L10n.string(.yeniAnahtar, language: lang)` ile değiştirin.
//
// Anahtarları `lowerCamelCase` tutun; `Key` enum içinde özelliğe göre gruplayın.
//
// Örnek:
//   `let lang = container.appSettings.selectedLanguage`
//   `Text(L10n.string(.tabHome, language: lang))`
//
// Veya `View` uzantısı: `Text(.tabHome).localized(in: container)`
//
import Foundation
import SwiftUI

enum L10n {

    enum Key: String, CaseIterable {
        // MARK: - Sekme çubuğu
        case tabHome
        case tabMyTasks
        case tabUsers
        case tabChats
        case tabSettings

        // MARK: - Kimlik doğrulama / Kayıt
        case registrationTitle
        case registrationPhoneLabel
        case registrationContinue
        case registrationHaveAccount
        case registrationCountrySelect
        case authWelcomeLine1
        case authWelcomeLine2
        case authNameLabel
        case authNamePlaceholder
        case authNewPasswordLabel
        case authConfirmPasswordLabel
        case authPasswordWeak
        case authPasswordMedium
        case authPasswordStrong
        case authPasswordVeryStrong
        case authSignInName
        case authSignInPassword
        case authSignInPasswordTooShort
        case authLoginFailed
        case authPasswordMustHaveUpper
        case authPasswordMustHaveDigits
        case authConfirmDoesNotMatch
        case authConfirmLengthMismatch
        case smsTitle
        case smsSubtitle
        case smsConfirm
        case smsResend
        case smsResendCountdown
        case signInLine1
        case signInLine2
        case signInButton
        case signInNoAccount
        case privacyFooter
        case countryPickerTitle

        // MARK: - Sohbetler
        case chatsPrivateChats
        case chatsGroups
        case chatsAllDepartments
        case chatsSearchPlaceholder
        case chatsAddUser
        case chatsEmptyMessages
        case chatsTypeMessage
        case chatsCallParticipant
        case chatsViewProfile
        case chatsMediaFiles
        case chatsDeleteChat
        case chatsMute
        case chatsUnmute
        case chatsMuteSheetTitle
        case chatsMuteSheetSubtitle
        case chatsMuteOptionLoud
        case chatsMuteOptionLoudSubtitle
        case chatsMuteOptionSilent
        case chatsMuteOptionSilentSubtitle
        case chatsConfirmDeleteTitle
        case chatsConfirmDeleteMessage

        // MARK: - Genel eylemler
        case actionYes
        case actionNo
        case actionCancel
        case actionConfirm
        case actionSave
        case actionDelete
        case actionClose
        case actionSelect

        // MARK: - Ayarlar
        case settingsTitle
        case settingsProfile
        case settingsStats
        case settingsLanguage
        case settingsTheme
        case settingsLogout

        // MARK: - Profil
        case profileTitle
        case profileNameLabel
        case profilePhoneLabel
        case profileDepartmentsLabel
        case profileAddPhoto
        case profileSaved

        // MARK: - Tema
        case themeTitle
        case themeIntroTitle
        case themeIntroSubtitle
        case themeDark
        case themeDarkSubtitle
        case themeLight
        case themeLightSubtitle

        // MARK: - Dil
        case languageTitle

        // MARK: - İstatistikler
        case statsTitle
        case statsTotal
        case statsCompleted
        case statsFailed
        case statsInProgress
        case statsReturned
        case statsUsers
        case statsCompletionRate
        case statsDailyTasks
        case statsBusiestDays
        case statsMostProductiveHours
        case statsWeeklyCompare
        case statsOldUnfinished
        case statsNoData

        // MARK: - Ortak metinler
        case search
        case allDepartments
        case status
        case department
        case noResults
        case noTasksFound
        case comingSoon

        // MARK: - Görev durumları
        case statusWaiting
        case statusInProgress
        case statusCompleted
        case statusCancelled
        case statusReturned

        // MARK: - Görev detay
        case taskContentTab
        case taskReviewTab
        case taskContent
        case taskStartDate
        case taskStartTime
        case taskDueDate
        case taskDueTime
        case taskAssignees
        case taskNoAssignees
        case taskFile
        case taskPhoto
        case taskCancelTask
        case taskNoDescription
        case taskUploading
        case taskComment
        case taskNoComment
        case taskFiles
        case taskPhotos
        case taskAccepted
        case taskReturned
        case taskAcceptButton
        case taskReturnButton
        case taskNoReviewItems

        // MARK: - Geri çevir sayfası
        case returnSheetTitle
        case returnSheetSubtitle
        case returnSheetPlaceholder
        case returnSheetCancel
        case returnSheetSend

        // MARK: - Görev oluştur
        case createTaskTitle
        case createTaskDept
        case createTaskDeptSelect
        case createTaskName
        case createTaskNamePlaceholder
        case createTaskDescription
        case createTaskAssignees
        case createTaskAddUser
        case createTaskDueDate
        case createTaskDueTime
        case createTaskUploadFile
        case createTaskAddFile
        case createTaskSubmit
        case createTaskPersonal
        case createTaskNewDept
        case createTaskDate
        case createTaskTime
        case createTaskAccept
        case createTaskClose

        // MARK: - Kullanıcı seçici
        case userPickerTitle
        case userPickerSearch
        case userPickerMyUsers
        case userPickerClose
        case userPickerAdd

        // MARK: - Kullanıcılar ekranı
        case usersTabUsers
        case usersTabInvitations
        case usersNoUsers
        case usersNoInvitations
        case usersDeleteConfirmTitle
        case usersDeleteConfirmMessage

        // MARK: - Kullanıcı kartı
        case userCardTasks
        case userCardCompleted
        case userCardActive

        // MARK: - Davet kartı
        case invitationReject
        case invitationAccept

        // MARK: - Kullanıcı ekleme sayfası
        case addUserTitle
        case addUserName
        case addUserPhone
        case addUserDeptSelect
        case addUserCancel
        case addUserInvite

        // MARK: - Sohbet detay
        case chatOnline
        case chatOffline
        case chatPhoto
        case chatFile
        case chatCamera

        // MARK: - Işlerim
        case myTasksTitle
        case myTasksEmpty
        case myTasksEmptyHint

        // MARK: - Bölüm seçici
        case deptPickerTitle
        case deptPickerAll

        // MARK: - İstatistik ek
        case statsTodayCompleted
        case statsThisWeek
        case statsLastWeek
        case statsMostActiveRange

        // MARK: - Haftanın günleri
        case weekdaySun
        case weekdayMon
        case weekdayTue
        case weekdayWed
        case weekdayThu
        case weekdayFri
        case weekdaySat
    }

    static func string(_ key: Key, language: Language) -> String {
        table[key]?[language] ?? table[key]?[.turkmen] ?? key.rawValue
    }

    // swiftlint:disable line_length
    private static let table: [Key: [Language: String]] = [

        // MARK: - Sekmeler
        .tabHome: [
            .turkmen: "Ýumuşlar", .turkish: "Görevler",
            .english: "Tasks", .russian: "Задачи"
        ],
        .tabMyTasks: [
            .turkmen: "Işlerim", .turkish: "İşlerim",
            .english: "My work", .russian: "Мои задачи"
        ],
        .tabUsers: [
            .turkmen: "Ulanyjylar", .turkish: "Kullanıcılar",
            .english: "Users", .russian: "Пользователи"
        ],
        .tabChats: [
            .turkmen: "Çatlar", .turkish: "Sohbetler",
            .english: "Chats", .russian: "Чаты"
        ],
        .tabSettings: [
            .turkmen: "Sazlamalar", .turkish: "Ayarlar",
            .english: "Settings", .russian: "Настройки"
        ],

        // MARK: - Kimlik doğrulama
        .registrationTitle: [
            .turkmen: "Registrasiýa", .turkish: "Kayıt",
            .english: "Registration", .russian: "Регистрация"
        ],
        .registrationPhoneLabel: [
            .turkmen: "Telefon belgi", .turkish: "Telefon numarası",
            .english: "Phone number", .russian: "Номер телефона"
        ],
        .registrationContinue: [
            .turkmen: "Dowam etmek", .turkish: "Devam et",
            .english: "Continue", .russian: "Продолжить"
        ],
        .registrationHaveAccount: [
            .turkmen: "Mende akkaunt bar!", .turkish: "Zaten bir hesabım var!",
            .english: "I already have an account", .russian: "У меня уже есть аккаунт"
        ],
        .registrationCountrySelect: [
            .turkmen: "Ýurt saýla", .turkish: "Ülke seç",
            .english: "Select country", .russian: "Выберите страну"
        ],
        .authWelcomeLine1: [
            .turkmen: "Ýatla programmasyna", .turkish: "Remember'a",
            .english: "Welcome to", .russian: "Добро пожаловать в"
        ],
        .authWelcomeLine2: [
            .turkmen: "hoş geldiňiz", .turkish: "hoş geldiniz",
            .english: "Remember", .russian: "Remember"
        ],
        .authNameLabel: [
            .turkmen: "Adyňyzy giriziň", .turkish: "Adınızı girin",
            .english: "Enter your name", .russian: "Введите имя"
        ],
        .authNamePlaceholder: [
            .turkmen: "Doly adyňyz", .turkish: "Tam adınız",
            .english: "Full name", .russian: "Полное имя"
        ],
        .authNewPasswordLabel: [
            .turkmen: "Täze açar söz", .turkish: "Yeni şifre",
            .english: "New password", .russian: "Новый пароль"
        ],
        .authConfirmPasswordLabel: [
            .turkmen: "Açar sözi tassyklaň", .turkish: "Şifreyi onayla",
            .english: "Confirm password", .russian: "Подтвердите пароль"
        ],
        .authPasswordWeak: [
            .turkmen: "Gowşak", .turkish: "Zayıf",
            .english: "Weak", .russian: "Слабый"
        ],
        .authPasswordMedium: [
            .turkmen: "Orta", .turkish: "Orta",
            .english: "Medium", .russian: "Средний"
        ],
        .authPasswordStrong: [
            .turkmen: "Güýçli", .turkish: "Güçlü",
            .english: "Strong", .russian: "Сильный"
        ],
        .authPasswordVeryStrong: [
            .turkmen: "Örän güýçli", .turkish: "Çok güçlü",
            .english: "Very strong", .russian: "Очень сильный"
        ],
        .authSignInName: [
            .turkmen: "Adyňyz ýa-da telefon", .turkish: "Adınız ya da telefon",
            .english: "Username or phone", .russian: "Имя или телефон"
        ],
        .authSignInPassword: [
            .turkmen: "Açar söz", .turkish: "Şifre",
            .english: "Password", .russian: "Пароль"
        ],
        .authSignInPasswordTooShort: [
            .turkmen: "Açar söz gysga (min 6)",
            .turkish: "Şifre çok kısa (min 6)",
            .english: "Password too short (min 6)",
            .russian: "Пароль короткий (мин. 6)"
        ],
        .authLoginFailed: [
            .turkmen: "Giriş başartmady. Maglumatlary barlaň.",
            .turkish: "Giriş başarısız. Bilgilerinizi kontrol edin.",
            .english: "Sign-in failed. Please check your details.",
            .russian: "Вход не выполнен. Проверьте данные."
        ],
        .authPasswordMustHaveUpper: [
            .turkmen: "Iň azyndan 1 uly harp bolmaly",
            .turkish: "En az 1 büyük harf olmalı",
            .english: "Must contain at least 1 uppercase letter",
            .russian: "Должна быть хотя бы 1 заглавная буква"
        ],
        .authPasswordMustHaveDigits: [
            .turkmen: "Iň azyndan 2 san bolmaly",
            .turkish: "En az 2 rakam olmalı",
            .english: "Must contain at least 2 digits",
            .russian: "Должно быть минимум 2 цифры"
        ],
        .authConfirmDoesNotMatch: [
            .turkmen: "Parollar gabat gelenok",
            .turkish: "Şifreler eşleşmiyor",
            .english: "Passwords do not match",
            .russian: "Пароли не совпадают"
        ],
        .authConfirmLengthMismatch: [
            .turkmen: "Parolyň uzynlygy gabat gelenok",
            .turkish: "Şifre uzunluğu eşleşmiyor",
            .english: "Password length does not match",
            .russian: "Длина пароля не совпадает"
        ],
        .smsTitle: [
            .turkmen: "SMS ugradyldy", .turkish: "SMS gönderildi",
            .english: "Code sent", .russian: "Код отправлен"
        ],
        .smsSubtitle: [
            .turkmen: "Telefonyňyza gelen 4 sanly kody giriziň",
            .turkish: "Telefonunuza gelen 4 haneli kodu girin",
            .english: "Enter the 4-digit code sent to your phone",
            .russian: "Введите 4-значный код из SMS"
        ],
        .smsConfirm: [
            .turkmen: "Tassyklamak", .turkish: "Onayla",
            .english: "Verify", .russian: "Подтвердить"
        ],
        .smsResend: [
            .turkmen: "Kody täzeden ugratmak", .turkish: "Kodu tekrar gönder",
            .english: "Resend code", .russian: "Отправить код снова"
        ],
        .smsResendCountdown: [
            .turkmen: "Kody täzeden ugratmak",
            .turkish: "Kodu tekrar gönder",
            .english: "Resend code",
            .russian: "Отправить код снова"
        ],
        .signInLine1: [
            .turkmen: "Ýatla programmasyna", .turkish: "Remember'a",
            .english: "Welcome to", .russian: "Добро пожаловать в"
        ],
        .signInLine2: [
            .turkmen: "hasaba giriş", .turkish: "hesabınıza giriş",
            .english: "Remember sign-in", .russian: "Remember — вход"
        ],
        .signInButton: [
            .turkmen: "Içeri girmek", .turkish: "Giriş yap",
            .english: "Sign in", .russian: "Войти"
        ],
        .signInNoAccount: [
            .turkmen: "Akkaundyňyz ýokmy? Registrasiýa",
            .turkish: "Hesabınız yok mu? Kayıt",
            .english: "No account? Register",
            .russian: "Нет аккаунта? Регистрация"
        ],
        .privacyFooter: [
            .turkmen: "Gizlinlik syýasaty", .turkish: "Gizlilik politikası",
            .english: "Privacy policy", .russian: "Политика конфиденциальности"
        ],
        .countryPickerTitle: [
            .turkmen: "Ýurt saýlaň", .turkish: "Ülke seçin",
            .english: "Select country", .russian: "Выберите страну"
        ],

        // MARK: - Sohbetler
        .chatsPrivateChats: [
            .turkmen: "Çatlar", .turkish: "Sohbetler",
            .english: "Chats", .russian: "Чаты"
        ],
        .chatsGroups: [
            .turkmen: "Toparlar", .turkish: "Gruplar",
            .english: "Groups", .russian: "Группы"
        ],
        .chatsAllDepartments: [
            .turkmen: "Ähli bölümler", .turkish: "Tüm bölümler",
            .english: "All departments", .russian: "Все отделы"
        ],
        .chatsSearchPlaceholder: [
            .turkmen: "Gözleg", .turkish: "Ara",
            .english: "Search", .russian: "Поиск"
        ],
        .chatsAddUser: [
            .turkmen: "Ulanyjy goşmak", .turkish: "Kullanıcı ekle",
            .english: "Add user", .russian: "Добавить пользователя"
        ],
        .chatsEmptyMessages: [
            .turkmen: "Heniz habar ýok", .turkish: "Henüz mesaj yok",
            .english: "No messages yet", .russian: "Сообщений пока нет"
        ],
        .chatsTypeMessage: [
            .turkmen: "Habar ýaz...", .turkish: "Mesaj yaz...",
            .english: "Type a message...", .russian: "Напишите сообщение..."
        ],
        .chatsCallParticipant: [
            .turkmen: "Jaň et", .turkish: "Ara",
            .english: "Call", .russian: "Позвонить"
        ],
        .chatsViewProfile: [
            .turkmen: "Profili gör", .turkish: "Profili görüntüle",
            .english: "View profile", .russian: "Открыть профиль"
        ],
        .chatsMediaFiles: [
            .turkmen: "Media faýllary", .turkish: "Medya dosyaları",
            .english: "Media & files", .russian: "Медиа и файлы"
        ],
        .chatsDeleteChat: [
            .turkmen: "Çaty poz", .turkish: "Sohbeti sil",
            .english: "Delete chat", .russian: "Удалить чат"
        ],
        .chatsMute: [
            .turkmen: "Sessizleştir", .turkish: "Sessize al",
            .english: "Mute", .russian: "Без звука"
        ],
        .chatsUnmute: [
            .turkmen: "Sesi aç", .turkish: "Sesi aç",
            .english: "Unmute", .russian: "Включить звук"
        ],
        .chatsMuteSheetTitle: [
            .turkmen: "Bildiriş sazlamasy", .turkish: "Bildirim ayarı",
            .english: "Notifications", .russian: "Уведомления"
        ],
        .chatsMuteSheetSubtitle: [
            .turkmen: "Bu çat üçin sesli ýa-da sessiz tertibi saýlaň",
            .turkish: "Bu sohbet için sesli veya sessiz mod seçin",
            .english: "Pick whether this chat plays a sound when a message arrives",
            .russian: "Выберите, играть ли звук для этого чата"
        ],
        .chatsMuteOptionLoud: [
            .turkmen: "Sesli", .turkish: "Sesli",
            .english: "Sound on", .russian: "Со звуком"
        ],
        .chatsMuteOptionLoudSubtitle: [
            .turkmen: "Habar gelende ses çalsyn", .turkish: "Mesaj geldiğinde ses çalsın",
            .english: "Play a sound on every message", .russian: "Играть звук при сообщениях"
        ],
        .chatsMuteOptionSilent: [
            .turkmen: "Sessiz", .turkish: "Sessiz",
            .english: "Silent", .russian: "Без звука"
        ],
        .chatsMuteOptionSilentSubtitle: [
            .turkmen: "Bildiriş geler, ýöne ses çalmaz", .turkish: "Bildirim gelir ama ses çalmaz",
            .english: "Notifications appear silently", .russian: "Уведомления без звука"
        ],
        .chatsConfirmDeleteTitle: [
            .turkmen: "Çaty pozmak isleýärsiňizmi?", .turkish: "Sohbeti silmek istiyor musunuz?",
            .english: "Delete this chat?", .russian: "Удалить чат?"
        ],
        .chatsConfirmDeleteMessage: [
            .turkmen: "Bu çatdaky ähli habarlar pozulýar we yzyna gaýdyp bolmaýar.",
            .turkish: "Bu sohbetteki tüm mesajlar silinir ve geri alınamaz.",
            .english: "All messages in this chat will be permanently deleted.",
            .russian: "Все сообщения чата будут удалены безвозвратно."
        ],

        // MARK: - Genel eylemler
        .actionYes: [
            .turkmen: "Howa", .turkish: "Evet", .english: "Yes", .russian: "Да"
        ],
        .actionNo: [
            .turkmen: "Yok", .turkish: "Hayır", .english: "No", .russian: "Нет"
        ],
        .actionCancel: [
            .turkmen: "Goý-bolsun", .turkish: "Vazgeç",
            .english: "Cancel", .russian: "Отмена"
        ],
        .actionConfirm: [
            .turkmen: "Tassyklamak", .turkish: "Onayla",
            .english: "Confirm", .russian: "Подтвердить"
        ],
        .actionSave: [
            .turkmen: "Saklamak", .turkish: "Kaydet",
            .english: "Save", .russian: "Сохранить"
        ],
        .actionDelete: [
            .turkmen: "Pozmak", .turkish: "Sil",
            .english: "Delete", .russian: "Удалить"
        ],
        .actionClose: [
            .turkmen: "Ýap", .turkish: "Kapat",
            .english: "Close", .russian: "Закрыть"
        ],
        .actionSelect: [
            .turkmen: "Saýlamak", .turkish: "Seç",
            .english: "Select", .russian: "Выбрать"
        ],

        // MARK: - Ayarlar
        .settingsTitle: [
            .turkmen: "Sazlamalar", .turkish: "Ayarlar",
            .english: "Settings", .russian: "Настройки"
        ],
        .settingsProfile: [
            .turkmen: "Profil", .turkish: "Profil",
            .english: "Profile", .russian: "Профиль"
        ],
        .settingsStats: [
            .turkmen: "Statistika", .turkish: "İstatistikler",
            .english: "Statistics", .russian: "Статистика"
        ],
        .settingsLanguage: [
            .turkmen: "Dil", .turkish: "Dil",
            .english: "Language", .russian: "Язык"
        ],
        .settingsTheme: [
            .turkmen: "Tema", .turkish: "Tema",
            .english: "Theme", .russian: "Тема"
        ],
        .settingsLogout: [
            .turkmen: "Çykmak", .turkish: "Çıkış",
            .english: "Sign out", .russian: "Выйти"
        ],

        // MARK: - Profil
        .profileTitle: [
            .turkmen: "Profil", .turkish: "Profil",
            .english: "Profile", .russian: "Профиль"
        ],
        .profileNameLabel: [
            .turkmen: "Adyňyz", .turkish: "Adınız",
            .english: "Your name", .russian: "Ваше имя"
        ],
        .profilePhoneLabel: [
            .turkmen: "Telefon", .turkish: "Telefon",
            .english: "Phone", .russian: "Телефон"
        ],
        .profileDepartmentsLabel: [
            .turkmen: "Bölümler", .turkish: "Bölümler",
            .english: "Departments", .russian: "Отделы"
        ],
        .profileAddPhoto: [
            .turkmen: "Surat goş", .turkish: "Fotoğraf ekle",
            .english: "Add photo", .russian: "Добавить фото"
        ],
        .profileSaved: [
            .turkmen: "Saklandy!", .turkish: "Kaydedildi!",
            .english: "Saved!", .russian: "Сохранено!"
        ],

        // MARK: - Tema
        .themeTitle: [
            .turkmen: "Tema", .turkish: "Tema",
            .english: "Theme", .russian: "Тема"
        ],
        .themeIntroTitle: [
            .turkmen: "Görnüş", .turkish: "Görünüm",
            .english: "Appearance", .russian: "Оформление"
        ],
        .themeIntroSubtitle: [
            .turkmen: "Programmaňyzy isleýşiňiz ýaly görkeziň",
            .turkish: "Uygulamayı istediğiniz gibi gösterin",
            .english: "Make the app feel like yours",
            .russian: "Настройте приложение по своему вкусу"
        ],
        .themeDark: [
            .turkmen: "Garaňky tema", .turkish: "Koyu tema",
            .english: "Dark theme", .russian: "Тёмная тема"
        ],
        .themeDarkSubtitle: [
            .turkmen: "Programmanyň esasy temasy", .turkish: "Uygulamanın varsayılan teması",
            .english: "The app's default theme", .russian: "Тема по умолчанию"
        ],
        .themeLight: [
            .turkmen: "Açyk tema", .turkish: "Açık tema",
            .english: "Light theme", .russian: "Светлая тема"
        ],
        .themeLightSubtitle: [
            .turkmen: "Ýagty we aýdyň reňk", .turkish: "Aydınlık ve net renk",
            .english: "Bright and crisp colors", .russian: "Яркие чистые цвета"
        ],

        // MARK: - Dil
        .languageTitle: [
            .turkmen: "Dil", .turkish: "Dil",
            .english: "Language", .russian: "Язык"
        ],

        // MARK: - İstatistikler
        .statsTitle: [
            .turkmen: "Statistika", .turkish: "İstatistikler",
            .english: "Statistics", .russian: "Статистика"
        ],
        .statsTotal: [
            .turkmen: "Jemi iş", .turkish: "Toplam görev",
            .english: "Total tasks", .russian: "Всего задач"
        ],
        .statsCompleted: [
            .turkmen: "Tamamlanan", .turkish: "Tamamlanan",
            .english: "Completed", .russian: "Выполнено"
        ],
        .statsFailed: [
            .turkmen: "Başarmadyk", .turkish: "Başarısız",
            .english: "Failed", .russian: "Не выполнено"
        ],
        .statsInProgress: [
            .turkmen: "Dowam edýän", .turkish: "Devam eden",
            .english: "In progress", .russian: "В процессе"
        ],
        .statsReturned: [
            .turkmen: "Yzyna gaýtarylan", .turkish: "Geri gönderilen",
            .english: "Returned", .russian: "Возвращено"
        ],
        .statsUsers: [
            .turkmen: "Ulanyjylar", .turkish: "Kullanıcılar",
            .english: "Users", .russian: "Пользователи"
        ],
        .statsCompletionRate: [
            .turkmen: "Tamamlanma derejesi", .turkish: "Tamamlanma oranı",
            .english: "Completion rate", .russian: "Уровень выполнения"
        ],
        .statsDailyTasks: [
            .turkmen: "Günlük ýumuşlar", .turkish: "Günlük görevler",
            .english: "Daily tasks", .russian: "Ежедневные задачи"
        ],
        .statsBusiestDays: [
            .turkmen: "Iň aktiw günler", .turkish: "En yoğun günler",
            .english: "Busiest days", .russian: "Самые загруженные дни"
        ],
        .statsMostProductiveHours: [
            .turkmen: "Iň önümçilikli sagatlar", .turkish: "En verimli saatler",
            .english: "Most productive hours", .russian: "Самые продуктивные часы"
        ],
        .statsWeeklyCompare: [
            .turkmen: "Hepdelik deňeşdirme", .turkish: "Haftalık karşılaştırma",
            .english: "Weekly comparison", .russian: "Сравнение по неделям"
        ],
        .statsOldUnfinished: [
            .turkmen: "Köp wagtdan tamamlanmadyk işler",
            .turkish: "Uzun süredir tamamlanmamış işler",
            .english: "Long-pending tasks",
            .russian: "Давно не завершённые задачи"
        ],
        .statsNoData: [
            .turkmen: "Heniz maglumat ýok", .turkish: "Henüz veri yok",
            .english: "No data yet", .russian: "Пока нет данных"
        ],

        // MARK: - Ortak
        .search: [
            .turkmen: "Gözleg", .turkish: "Ara",
            .english: "Search", .russian: "Поиск"
        ],
        .allDepartments: [
            .turkmen: "Hemmesi", .turkish: "Hepsi",
            .english: "All", .russian: "Все"
        ],
        .status: [
            .turkmen: "Ýagdaý", .turkish: "Durum",
            .english: "Status", .russian: "Статус"
        ],
        .department: [
            .turkmen: "Bölüm", .turkish: "Bölüm",
            .english: "Department", .russian: "Отдел"
        ],
        .noResults: [
            .turkmen: "Tapylmady", .turkish: "Sonuç yok",
            .english: "No results", .russian: "Нет результатов"
        ],
        .noTasksFound: [
            .turkmen: "Iş tapylmady", .turkish: "Görev bulunamadı",
            .english: "No tasks found", .russian: "Задач не найдено"
        ],
        .comingSoon: [
            .turkmen: "Ýakynda", .turkish: "Yakında",
            .english: "Coming soon", .russian: "Скоро"
        ],

        // MARK: - Görev durumları
        .statusWaiting: [
            .turkmen: "Garaşylýar", .turkish: "Bekliyor",
            .english: "Waiting", .russian: "Ожидание"
        ],
        .statusInProgress: [
            .turkmen: "Ýerine ýetirilýär", .turkish: "Devam ediyor",
            .english: "In progress", .russian: "В процессе"
        ],
        .statusCompleted: [
            .turkmen: "Tamamlandy", .turkish: "Tamamlandı",
            .english: "Completed", .russian: "Выполнено"
        ],
        .statusCancelled: [
            .turkmen: "Ýatyryldy", .turkish: "İptal edildi",
            .english: "Cancelled", .russian: "Отменено"
        ],
        .statusReturned: [
            .turkmen: "Yzyna gaýtaryldy", .turkish: "Geri gönderildi",
            .english: "Returned", .russian: "Возвращено"
        ],

        // MARK: - Görev detay
        .taskContentTab: [
            .turkmen: "Işiň mazmuny", .turkish: "Görev içeriği",
            .english: "Task content", .russian: "Содержание задачи"
        ],
        .taskReviewTab: [
            .turkmen: "Barlanmaly işler", .turkish: "İncelenecek işler",
            .english: "Review items", .russian: "На проверку"
        ],
        .taskContent: [
            .turkmen: "Mazmuny", .turkish: "İçerik",
            .english: "Content", .russian: "Содержание"
        ],
        .taskStartDate: [
            .turkmen: "Başlanan güni", .turkish: "Başlangıç tarihi",
            .english: "Start date", .russian: "Дата начала"
        ],
        .taskStartTime: [
            .turkmen: "Başlanan wagty", .turkish: "Başlangıç saati",
            .english: "Start time", .russian: "Время начала"
        ],
        .taskDueDate: [
            .turkmen: "Tamamlanmaly güni", .turkish: "Bitiş tarihi",
            .english: "Due date", .russian: "Дата завершения"
        ],
        .taskDueTime: [
            .turkmen: "Tamamlanmaly wagty", .turkish: "Bitiş saati",
            .english: "Due time", .russian: "Время завершения"
        ],
        .taskAssignees: [
            .turkmen: "Degişli adamlar", .turkish: "Atanan kişiler",
            .english: "Assignees", .russian: "Исполнители"
        ],
        .taskNoAssignees: [
            .turkmen: "Degişli adam ýok", .turkish: "Atanmış kişi yok",
            .english: "No assignees", .russian: "Нет исполнителей"
        ],
        .taskFile: [
            .turkmen: "Faýl", .turkish: "Dosya",
            .english: "File", .russian: "Файл"
        ],
        .taskPhoto: [
            .turkmen: "Surat", .turkish: "Fotoğraf",
            .english: "Photo", .russian: "Фото"
        ],
        .taskCancelTask: [
            .turkmen: "Işi ýatyrmak", .turkish: "Görevi iptal et",
            .english: "Cancel task", .russian: "Отменить задачу"
        ],
        .taskNoDescription: [
            .turkmen: "Düşündiriş ýok", .turkish: "Açıklama yok",
            .english: "No description", .russian: "Нет описания"
        ],
        .taskUploading: [
            .turkmen: "Ýüklenýär...", .turkish: "Yükleniyor...",
            .english: "Uploading...", .russian: "Загрузка..."
        ],
        .taskComment: [
            .turkmen: "Kommentariýa", .turkish: "Yorum",
            .english: "Comment", .russian: "Комментарий"
        ],
        .taskNoComment: [
            .turkmen: "Kommentariýa ýok", .turkish: "Yorum yok",
            .english: "No comment", .russian: "Нет комментария"
        ],
        .taskFiles: [
            .turkmen: "Faýllar", .turkish: "Dosyalar",
            .english: "Files", .russian: "Файлы"
        ],
        .taskPhotos: [
            .turkmen: "Suratlar", .turkish: "Fotoğraflar",
            .english: "Photos", .russian: "Фотографии"
        ],
        .taskAccepted: [
            .turkmen: "Kabul edildi", .turkish: "Kabul edildi",
            .english: "Accepted", .russian: "Принято"
        ],
        .taskReturned: [
            .turkmen: "Yzyna gaýtaryldy", .turkish: "Geri gönderildi",
            .english: "Returned", .russian: "Возвращено"
        ],
        .taskAcceptButton: [
            .turkmen: "Kabul etmek", .turkish: "Kabul et",
            .english: "Accept", .russian: "Принять"
        ],
        .taskReturnButton: [
            .turkmen: "Yzyna gaýtarmak", .turkish: "Geri gönder",
            .english: "Return", .russian: "Вернуть"
        ],
        .taskNoReviewItems: [
            .turkmen: "Barlanmaly iş ýok", .turkish: "İncelenecek iş yok",
            .english: "No items to review", .russian: "Нечего проверять"
        ],

        // MARK: - Geri çevir sayfası
        .returnSheetTitle: [
            .turkmen: "Yzyna gaýtarmak", .turkish: "Geri gönder",
            .english: "Return task", .russian: "Вернуть задачу"
        ],
        .returnSheetSubtitle: [
            .turkmen: "Sebäbini ýazyň", .turkish: "Nedenini yazın",
            .english: "Please describe the reason", .russian: "Укажите причину"
        ],
        .returnSheetPlaceholder: [
            .turkmen: "", .turkish: "",
            .english: "", .russian: ""
        ],
        .returnSheetCancel: [
            .turkmen: "Goý-bolsun", .turkish: "Vazgeç",
            .english: "Cancel", .russian: "Отмена"
        ],
        .returnSheetSend: [
            .turkmen: "Iber", .turkish: "Gönder",
            .english: "Send", .russian: "Отправить"
        ],

        // MARK: - Görev oluştur
        .createTaskTitle: [
            .turkmen: "Täze ýumuş", .turkish: "Yeni görev",
            .english: "New task", .russian: "Новая задача"
        ],
        .createTaskDept: [
            .turkmen: "Bölüm", .turkish: "Bölüm",
            .english: "Department", .russian: "Отдел"
        ],
        .createTaskDeptSelect: [
            .turkmen: "Bölüm saýlaň", .turkish: "Bölüm seçin",
            .english: "Select department", .russian: "Выберите отдел"
        ],
        .createTaskName: [
            .turkmen: "Işiň ady", .turkish: "Görev adı",
            .english: "Task name", .russian: "Название задачи"
        ],
        .createTaskNamePlaceholder: [
            .turkmen: "Ady giriziň", .turkish: "Ad girin",
            .english: "Enter name", .russian: "Введите название"
        ],
        .createTaskDescription: [
            .turkmen: "Düşündiriş", .turkish: "Açıklama",
            .english: "Description", .russian: "Описание"
        ],
        .createTaskAssignees: [
            .turkmen: "Degişli adamlar", .turkish: "Atanan kişiler",
            .english: "Assignees", .russian: "Исполнители"
        ],
        .createTaskAddUser: [
            .turkmen: "Ulanyjy goş", .turkish: "Kullanıcı ekle",
            .english: "Add user", .russian: "Добавить пользователя"
        ],
        .createTaskDueDate: [
            .turkmen: "Tamamlanmaly güni", .turkish: "Bitiş tarihi",
            .english: "Due date", .russian: "Срок выполнения"
        ],
        .createTaskDueTime: [
            .turkmen: "Tamamlanmaly wagty", .turkish: "Bitiş saati",
            .english: "Due time", .russian: "Время завершения"
        ],
        .createTaskUploadFile: [
            .turkmen: "Faýl ýükle", .turkish: "Dosya yükle",
            .english: "Upload file", .russian: "Загрузить файл"
        ],
        .createTaskAddFile: [
            .turkmen: "Faýl goş", .turkish: "Dosya ekle",
            .english: "Add file", .russian: "Добавить файл"
        ],
        .createTaskSubmit: [
            .turkmen: "Döretmek", .turkish: "Oluştur",
            .english: "Create", .russian: "Создать"
        ],
        .createTaskPersonal: [
            .turkmen: "Şahsy", .turkish: "Kişisel",
            .english: "Personal", .russian: "Личное"
        ],
        .createTaskNewDept: [
            .turkmen: "Täze bölüm", .turkish: "Yeni bölüm",
            .english: "New department", .russian: "Новый отдел"
        ],
        .createTaskDate: [
            .turkmen: "Sene", .turkish: "Tarih",
            .english: "Date", .russian: "Дата"
        ],
        .createTaskTime: [
            .turkmen: "Wagt", .turkish: "Saat",
            .english: "Time", .russian: "Время"
        ],
        .createTaskAccept: [
            .turkmen: "Kabul et", .turkish: "Kabul et",
            .english: "Accept", .russian: "Принять"
        ],
        .createTaskClose: [
            .turkmen: "Ýap", .turkish: "Kapat",
            .english: "Close", .russian: "Закрыть"
        ],

        // MARK: - Kullanıcı seçici
        .userPickerTitle: [
            .turkmen: "Ulanyjy saýlaň", .turkish: "Kullanıcı seçin",
            .english: "Select user", .russian: "Выберите пользователя"
        ],
        .userPickerSearch: [
            .turkmen: "Gözleg", .turkish: "Ara",
            .english: "Search", .russian: "Поиск"
        ],
        .userPickerMyUsers: [
            .turkmen: "Meniň ulanyjylarym", .turkish: "Kullanıcılarım",
            .english: "My users", .russian: "Мои пользователи"
        ],
        .userPickerClose: [
            .turkmen: "Ýap", .turkish: "Kapat",
            .english: "Close", .russian: "Закрыть"
        ],
        .userPickerAdd: [
            .turkmen: "Goş", .turkish: "Ekle",
            .english: "Add", .russian: "Добавить"
        ],

        // MARK: - Kullanıcılar ekranı
        .usersTabUsers: [
            .turkmen: "Ulanyjylar", .turkish: "Kullanıcılar",
            .english: "Users", .russian: "Пользователи"
        ],
        .usersTabInvitations: [
            .turkmen: "Meni çagyranlar", .turkish: "Davetler",
            .english: "Invitations", .russian: "Приглашения"
        ],
        .usersNoUsers: [
            .turkmen: "Ulanyjy ýok", .turkish: "Kullanıcı yok",
            .english: "No users", .russian: "Нет пользователей"
        ],
        .usersNoInvitations: [
            .turkmen: "Çakylyk ýok", .turkish: "Davet yok",
            .english: "No invitations", .russian: "Нет приглашений"
        ],
        .usersDeleteConfirmTitle: [
            .turkmen: "Ulanyjyny pozmak?", .turkish: "Kullanıcıyı sil?",
            .english: "Delete user?", .russian: "Удалить пользователя?"
        ],
        .usersDeleteConfirmMessage: [
            .turkmen: "Bu amaly yzyna gaýtaryp bolmaýar.",
            .turkish: "Bu işlem geri alınamaz.",
            .english: "This action cannot be undone.",
            .russian: "Это действие нельзя отменить."
        ],

        // MARK: - Kullanıcı kartı
        .userCardTasks: [
            .turkmen: "ýumuşlar", .turkish: "görevler",
            .english: "tasks", .russian: "задач"
        ],
        .userCardCompleted: [
            .turkmen: "ýerine ýetirilen", .turkish: "tamamlanan",
            .english: "completed", .russian: "выполнено"
        ],
        .userCardActive: [
            .turkmen: "aktiw", .turkish: "aktif",
            .english: "active", .russian: "активных"
        ],

        // MARK: - Davet kartı
        .invitationReject: [
            .turkmen: "Ýatyrmak", .turkish: "Reddet",
            .english: "Reject", .russian: "Отклонить"
        ],
        .invitationAccept: [
            .turkmen: "Kabul etmek", .turkish: "Kabul et",
            .english: "Accept", .russian: "Принять"
        ],

        // MARK: - Kullanıcı ekleme
        .addUserTitle: [
            .turkmen: "Ulanyjy goşmak", .turkish: "Kullanıcı ekle",
            .english: "Add user", .russian: "Добавить пользователя"
        ],
        .addUserName: [
            .turkmen: "Ady", .turkish: "Ad",
            .english: "Name", .russian: "Имя"
        ],
        .addUserPhone: [
            .turkmen: "Telefon belgi", .turkish: "Telefon numarası",
            .english: "Phone number", .russian: "Номер телефона"
        ],
        .addUserDeptSelect: [
            .turkmen: "Bölüm saýlaň", .turkish: "Bölüm seçin",
            .english: "Select department", .russian: "Выберите отдел"
        ],
        .addUserCancel: [
            .turkmen: "Goý-bolsun", .turkish: "Vazgeç",
            .english: "Cancel", .russian: "Отмена"
        ],
        .addUserInvite: [
            .turkmen: "Çagyrmak", .turkish: "Davet et",
            .english: "Invite", .russian: "Пригласить"
        ],

        // MARK: - Sohbet detay
        .chatOnline: [
            .turkmen: "Onlaýn", .turkish: "Çevrimiçi",
            .english: "Online", .russian: "В сети"
        ],
        .chatOffline: [
            .turkmen: "Awtonom", .turkish: "Çevrimdışı",
            .english: "Offline", .russian: "Не в сети"
        ],
        .chatPhoto: [
            .turkmen: "Surat", .turkish: "Fotoğraf",
            .english: "Photo", .russian: "Фото"
        ],
        .chatFile: [
            .turkmen: "Faýl", .turkish: "Dosya",
            .english: "File", .russian: "Файл"
        ],
        .chatCamera: [
            .turkmen: "Kamera", .turkish: "Kamera",
            .english: "Camera", .russian: "Камера"
        ],

        // MARK: - Işlerim
        .myTasksTitle: [
            .turkmen: "Işlerim", .turkish: "İşlerim",
            .english: "My tasks", .russian: "Мои задачи"
        ],
        .myTasksEmpty: [
            .turkmen: "Heniz iş ýok", .turkish: "Henüz görev yok",
            .english: "No tasks yet", .russian: "Задач пока нет"
        ],
        .myTasksEmptyHint: [
            .turkmen: "Iş berilende şu ýerde görüner", .turkish: "Görev atandığında burada görünecek",
            .english: "Tasks will appear here when assigned", .russian: "Задачи появятся здесь при назначении"
        ],

        // MARK: - Bölüm seçici
        .deptPickerTitle: [
            .turkmen: "Bölüm saýlaň", .turkish: "Bölüm seçin",
            .english: "Select department", .russian: "Выберите отдел"
        ],
        .deptPickerAll: [
            .turkmen: "Hemmesi", .turkish: "Hepsi",
            .english: "All", .russian: "Все"
        ],

        // MARK: - İstatistik ek
        .statsTodayCompleted: [
            .turkmen: "Şu gün tamamlanan", .turkish: "Bugün tamamlanan",
            .english: "Completed today", .russian: "Выполнено сегодня"
        ],
        .statsThisWeek: [
            .turkmen: "Bu hepde", .turkish: "Bu hafta",
            .english: "This week", .russian: "Эта неделя"
        ],
        .statsLastWeek: [
            .turkmen: "Geçen hepde", .turkish: "Geçen hafta",
            .english: "Last week", .russian: "Прошлая неделя"
        ],
        .statsMostActiveRange: [
            .turkmen: "Iň aktiw aralyk", .turkish: "En aktif aralık",
            .english: "Most active range", .russian: "Самый активный диапазон"
        ],

        // MARK: - Haftanın günleri
        .weekdaySun: [
            .turkmen: "Ý", .turkish: "Pz", .english: "Su", .russian: "Вс"
        ],
        .weekdayMon: [
            .turkmen: "D", .turkish: "Pt", .english: "Mo", .russian: "Пн"
        ],
        .weekdayTue: [
            .turkmen: "S", .turkish: "Sa", .english: "Tu", .russian: "Вт"
        ],
        .weekdayWed: [
            .turkmen: "Ç", .turkish: "Ça", .english: "We", .russian: "Ср"
        ],
        .weekdayThu: [
            .turkmen: "P", .turkish: "Pe", .english: "Th", .russian: "Чт"
        ],
        .weekdayFri: [
            .turkmen: "A", .turkish: "Cu", .english: "Fr", .russian: "Пт"
        ],
        .weekdaySat: [
            .turkmen: "Ş", .turkish: "Ct", .english: "Sa", .russian: "Сб"
        ]
    ]
    // swiftlint:enable line_length
}

extension Language {
    var menuCode: String {
        switch self {
        case .turkmen: return "TM"
        case .turkish: return "TR"
        case .english: return "EN"
        case .russian: return "RU"
        }
    }

    static func from(menuCode: String) -> Language {
        switch menuCode.uppercased() {
        case "TR": return .turkish
        case "EN": return .english
        case "RU": return .russian
        default: return .turkmen
        }
    }
}

// MARK: - SwiftUI kolaylıkları

/// Görünümlerin her yerine `language:` iletmek zorunda kalmamak için kısayol.
/// DI kapsayıcısından aktif dili bir kez okuyup gövde içinde `tr(.tabHome)` gibi çağırın.
extension View {
    func localized(_ key: L10n.Key, in container: DIContainer) -> Text {
        Text(L10n.string(key, language: container.appSettings.selectedLanguage))
    }
}
