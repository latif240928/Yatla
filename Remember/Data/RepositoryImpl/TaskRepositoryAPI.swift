// `TaskRepository` için gerçek ağ katmanı; `openapi.json` içindeki `/api/v1/tasks` yüzeyine karşılık gelir:
//
//   GET    /api/v1/tasks                                 -> [TaskResponse]
//   POST   /api/v1/tasks                                 -> TaskResponse
//   GET    /api/v1/tasks/{task_id}                       -> TaskResponse
//   PUT    /api/v1/tasks/{task_id}                       -> TaskResponse
//   DELETE /api/v1/tasks/{task_id}                       -> 200 OK
//   PATCH  /api/v1/tasks/{task_id}/status?status=        -> TaskResponse  (durum sorgu parametresi)
//   POST   /api/v1/tasks/{task_id}/assignees/{user_id}   -> TaskResponse
//   DELETE /api/v1/tasks/{task_id}/assignees/{user_id}   -> TaskResponse
//   GET    /api/v1/tasks/{task_id}/comments              -> [TaskCommentResponse]
//   POST   /api/v1/tasks/{task_id}/comments?text=        -> TaskCommentResponse
//   POST   /api/v1/tasks/{task_id}/files?name=&format=&url=  -> TaskFileResponse
//
// Sunucunun `TaskResponse` gövdesi kasıtlı olarak incedir — yalnızca kullanıcı / departman kimlikleri gelir.
// Zengin `TaskItem` modelinde yardımcı koleksiyonlar burada boş bırakılır; ViewModel'ler atananlar / dosyalar / yorumlar
// için depo metotları veya `UserRepository` ile birleştirerek doldurur.
import Foundation

final class TaskRepositoryAPI: TaskRepository {
    private let network: NetworkService

    init(network: NetworkService = .shared) {
        self.network = network
    }

    // MARK: - Okuma

    func getTasks() async throws -> [TaskItem] {
        let dtos: [TaskItemDTO] = try await network.request(path: "/tasks", method: .get)
        return dtos.map { $0.toDomain() }
    }

    // MARK: - Yazma

    /// Yeni backend'de `/tasks/import` yoktuğundan, kabul edilen teklifleri standart oluşturma uç noktasıyla yeniden yazarak listeye ekleriz.
    func addTask(_ task: TaskItem) async throws {
        let create = CreateTask(
            name: task.title,
            mazmuny: task.description,
            department: task.departmentId.isEmpty ? nil : Department(id: task.departmentId, name: task.department),
            assigneeIDs: task.assigneeIds,
            creatorId: task.creatorId,
            endDate: task.dueDate,
            endTime: task.dueDate,
            files: task.files
        )
        _ = try await createTask(create)
    }

    func createTask(_ task: CreateTask) async throws -> TaskItem {
        struct CreateTaskRequest: Encodable {
            let title: String
            let description: String?
            let departmentId: String?
            let dueDate: Date?
            let assigneeIds: [String]
            let startDate: Date?

            enum CodingKeys: String, CodingKey {
                case title, description
                case departmentId = "department_id"
                case dueDate = "due_date"
                case assigneeIds = "assignee_ids"
                case startDate = "start_date"
            }
        }

        let dueDate = combine(date: task.endDate, time: task.endTime)
        let body = CreateTaskRequest(
            title: task.name,
            description: task.mazmuny.isEmpty ? nil : task.mazmuny,
            departmentId: task.department?.id,
            dueDate: dueDate,
            assigneeIds: task.assigneeIDs,
            startDate: task.endDate
        )

        let dto: TaskItemDTO = try await network.request(
            path: "/tasks",
            method: .post,
            bodyObject: body
        )
        return dto.toDomain()
    }

    func updateStatus(id: String, status: TaskStatus) async throws -> TaskItem {
        // Backend takes the status as a *query parameter*, not a JSON body.
        let dto: TaskItemDTO = try await network.request(
            path: "/tasks/\(id)/status",
            method: .patch,
            queryItems: [URLQueryItem(name: "status", value: status.backendWireValue)]
        )
        return dto.toDomain()
    }

    func deleteTask(id: String) async throws {
        _ = try await network.request(path: "/tasks/\(id)", method: .delete) as EmptyResponseDTO
    }

    func addAssignee(taskID: String, userID: String) async throws -> TaskItem {
        // No body — both IDs travel in the URL path.
        let dto: TaskItemDTO = try await network.request(
            path: "/tasks/\(taskID)/assignees/\(userID)",
            method: .post
        )
        return dto.toDomain()
    }

    func removeAssignee(taskID: String, assigneeID: String) async throws -> TaskItem {
        let dto: TaskItemDTO = try await network.request(
            path: "/tasks/\(taskID)/assignees/\(assigneeID)",
            method: .delete
        )
        return dto.toDomain()
    }

    func addComment(taskID: String, text: String) async throws -> TaskComment {
        // Backend takes `text` as a query param.
        let dto: TaskCommentDTO = try await network.request(
            path: "/tasks/\(taskID)/comments",
            method: .post,
            queryItems: [URLQueryItem(name: "text", value: text)]
        )
        // We only have the user_id from the response — surface a placeholder
        // user; the calling view-model can resolve the real user via the
        // user repository if it wants to.
        return dto.toDomainPlaceholder()
    }

    func uploadFile(taskId: String, fileURL: URL) async throws -> TaskFile {
        // The OpenAPI shape registers a *URL reference* rather than a
        // multipart upload. The frontend is expected to upload binary
        // data to its own object-storage bucket and then call this
        // endpoint with the resulting URL.
        let name = fileURL.lastPathComponent
        let ext = fileURL.pathExtension
        var query: [URLQueryItem] = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "url", value: fileURL.absoluteString)
        ]
        if !ext.isEmpty { query.append(URLQueryItem(name: "format", value: ext)) }

        let dto: TaskFileDTO = try await network.request(
            path: "/tasks/\(taskId)/files",
            method: .post,
            queryItems: query
        )
        return dto.toDomain()
    }

    // MARK: - Yardımcılar

    /// Combines a `date` (year/month/day) and a `time` (hour/minute) into a
    /// single calendar moment, defaulting to `date` when the merge fails.
    private func combine(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let timeParts = calendar.dateComponents([.hour, .minute, .second], from: time)
        return calendar.date(
            bySettingHour: timeParts.hour ?? 0,
            minute: timeParts.minute ?? 0,
            second: timeParts.second ?? 0,
            of: date
        ) ?? date
    }
}
