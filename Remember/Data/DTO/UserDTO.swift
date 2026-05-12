// `openapi.json` içindeki `UserResponse` ile eşleşir.
//
// {
//   "id": "...",
//   "name": "...",
//   "phone": "...",
//   "avatar_url": null,
//   "is_admin": false,
//   "department_ids": ["..."],
//   "created_at": "2024-01-01T10:00:00Z"
// }
import Foundation

struct UserDTO: Codable {
    let id: String
    let name: String
    let phone: String
    let avatarURL: String?
    let isAdmin: Bool?
    let departmentIds: [String]?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, phone
        case avatarURL = "avatar_url"
        case isAdmin = "is_admin"
        case departmentIds = "department_ids"
        case createdAt = "created_at"
    }

    func toDomain() -> User {
        User(
            id: id,
            name: name,
            phone: phone,
            departmentIds: departmentIds ?? [],
            avatarURL: avatarURL,
            isAdmin: isAdmin ?? false,
            createdAt: createdAt
        )
    }
}

/// OpenAPI şemasındaki `UserTaskStats` ile uyumludur.
struct UserTaskStatsDTO: Codable {
    let userId: String
    let assignedTaskCount: Int
    let completedTaskCount: Int
    let pendingTaskCount: Int

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case assignedTaskCount = "assigned_task_count"
        case completedTaskCount = "completed_task_count"
        case pendingTaskCount = "pending_task_count"
    }

    func toDomain() -> UserTaskStats {
        UserTaskStats(
            userId: userId,
            assignedTaskCount: assignedTaskCount,
            completedTaskCount: completedTaskCount,
            pendingTaskCount: pendingTaskCount
        )
    }
}
