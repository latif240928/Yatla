// Görev veri kaynağı: CRUD, atananlar, yorum ve dosya yükleme.
import Foundation

protocol TaskRepository {
    func getTasks() async throws -> [TaskItem]

    func createTask(_ task: CreateTask) async throws -> TaskItem

    /// Hazır `TaskItem`'ı doğrudan ekler. Kabul edilmiş görev teklifinin normal oluşturma formu olmadan listeye düşmesi için kullanılır.
    func addTask(_ task: TaskItem) async throws

    func updateStatus(id: String, status: TaskStatus) async throws -> TaskItem

    func deleteTask(id: String) async throws

    func addAssignee(taskID: String, userID: String) async throws -> TaskItem

    func removeAssignee(taskID: String, assigneeID: String) async throws -> TaskItem

    func addComment(taskID: String, text: String) async throws -> TaskComment

    func uploadFile(taskId: String, fileURL: URL) async throws -> TaskFile
}
