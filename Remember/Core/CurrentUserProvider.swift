// Oturumdaki kullanıcı için tek doğruluk kaynağı: `SessionStore`.
// ViewModel'ler tercihen `@EnvironmentObject` veya `DIContainer.shared.session` kullanmalıdır.
//
// `CurrentUserProvider.user` eski çağrı noktaları için ince bir yüzdür; zamanla `SessionStore`'a geçilir.
import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {

    @Published private(set) var currentUser: User

    /// Kimlik doğrulama tamamlanana kadar yer tutucu; başarılı girişten sonra mutlaka `signIn(user:)` ile değiştirilmelidir.
    static let placeholderUser = User(
        id: "current-user",
        name: "Abdullatif Durdybayew",
        phone: "+993 62445524",
        departmentIds: ["dept-1"]
    )

    /// Yer tutucu kullanıcı ile başlar; sunucudan gerçek `User` gelince `signIn` ile güncellenir.
    init(initial: User? = nil) {
        self.currentUser = initial ?? SessionStore.placeholderUser
    }

    func signIn(user: User) {
        currentUser = user
    }

    func updateProfile(name: String? = nil, phone: String? = nil, departmentIds: [String]? = nil) {
        var u = currentUser
        if let name { u.name = name }
        if let phone { u.phone = phone }
        if let departmentIds { u.departmentIds = departmentIds }
        currentUser = u
    }

    func signOut() {
        currentUser = SessionStore.placeholderUser
    }
}

// MARK: - Geriye dönük uyumluluk
//
// Eski kod `CurrentUserProvider.user.id` kullanmaya devam edebilir; yeni kod `@EnvironmentObject var session: SessionStore` tercih etmelidir.
enum CurrentUserProvider {
    @MainActor
    static var user: User { DIContainer.shared.session.currentUser }
}
