// `openapi.json` içindeki `TaskResponse` ile eşleşir. Sunucu görev gövdesini sade tutar:
//
//   - `start_date` yok (istemci oluşturma zamanını `start_date` olarak kullanır)
//   - Tam `assignees` nesneleri yok; yalnızca `assignee_ids`
//   - Departman adı yok; yalnızca `department_id`
//   - `files` / `comments` yok; ayrı uç noktalardan çekilir
//
// Domain `TaskItem` şeklini korumak için eksik parçalar `TaskMapper` / `TaskRepositoryAPI` içinde
// tamamlanır (ör. `/tasks/{id}/comments` veya kullanıcı deposu ile).
import Foundation

struct TaskItemDTO: Codable {
    let id: String
    let title: String
    let description: String?
    let status: String
    let departmentId: String?
    let creatorId: String
    let number: Int
    let assigneeIds: [String]
    let dueDate: Date?
    let createdAt: Date
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, description, status, number
        case departmentId = "department_id"
        case creatorId = "creator_id"
        case assigneeIds = "assignee_ids"
        case dueDate = "due_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Map to the rich domain `TaskItem`. The mapper falls back to safe
    /// defaults for the fields the backend no longer ships — repositories
    /// can later enrich the result by joining against the user / comment /
    /// file endpoints.
    func toDomain(
        departmentName: String = "",
        assignees: [TaskAssignee] = [],
        files: [TaskFile] = [],
        comments: [TaskComment] = []
    ) -> TaskItem {
        TaskItem(
            id: id,
            title: title,
            description: description ?? "",
            status: TaskStatus.fromWire(status),
            department: departmentName,
            departmentId: departmentId ?? "",
            assignees: assignees,
            assigneeIds: assigneeIds,
            creatorId: creatorId,
            createdAt: createdAt,
            startDate: createdAt,
            dueDate: dueDate ?? createdAt,
            files: files,
            comments: comments,
            number: number
        )
    }
}
