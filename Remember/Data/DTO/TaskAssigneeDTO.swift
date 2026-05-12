// Sunucunun `TaskCommentResponse` ve `TaskFileResponse` gövdeleri doğrudan bu DTO'lara karşılık gelir.
// `TaskAssigneeDTO` (tam kullanıcı + atanan durumu) API tarafından artık gönderilmez; `TaskResponse.assignee_ids`
// ile kullanıcı deposu birleştirilerek depo katmanında yeniden kurulur — burada ince bellek içi temsil tutulur.
import Foundation

/// Yalnızca bellek içi — v0.1 şema geçişinden sonra kablodan çözülmez.
/// `TaskItem.assignees` ve mevcut arayüz derlemesi için tutulur.
struct TaskAssigneeDTO {
    let id: String
    let user: UserDTO
    let status: String

    func toDomain() -> TaskAssignee {
        TaskAssignee(
            id: id,
            user: user.toDomain(),
            status: TaskStatus.fromWire(status)
        )
    }
}

/// `TaskCommentResponse` ile aynı yapı. Sunucu yalnızca `user_id` döner (tam kullanıcı nesnesi yok).
/// Domain `TaskComment` oluşturulurken depo / eşleyici kullanıcıyı ayrıca yükler.
struct TaskCommentDTO: Codable {
    let id: String
    let userId: String
    let text: String
    let date: Date

    enum CodingKeys: String, CodingKey {
        case id, text, date
        case userId = "user_id"
    }

    func toDomain(user: User) -> TaskComment {
        TaskComment(id: id, user: user, text: text, date: date)
    }

    /// Kullanıcı henüz çözülmediyse yer tutucu ile yorum göstermek için (arayüz boş kalmasın).
    func toDomainPlaceholder() -> TaskComment {
        let placeholder = User(id: userId, name: "", phone: "")
        return TaskComment(id: id, user: placeholder, text: text, date: date)
    }
}

/// `TaskFileResponse` ile aynı yapı.
struct TaskFileDTO: Codable {
    let id: String
    let name: String
    let format: String?
    let url: String

    func toDomain() -> TaskFile {
        TaskFile(id: id, name: name, format: format ?? "", url: url)
    }
}
