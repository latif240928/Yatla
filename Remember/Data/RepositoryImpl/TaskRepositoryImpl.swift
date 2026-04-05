// Data/Repositories/TaskRepositoryImpl.swift
import Foundation

final class TaskRepositoryImpl: TaskRepository {

    private var tasks: [TaskItem] = TaskItem.createdMockList

    func getTasks() async throws -> [TaskItem] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return tasks
    }

    func createTask(_ task: CreateTask) async throws -> TaskItem {
        try await Task.sleep(nanoseconds: 500_000_000)

        let newTask = TaskItem(
            id: UUID().uuidString,
            title: task.name,
            description: task.mazmuny,
            status: .waiting,
            department: task.department?.name ?? "",
            departmentId: task.department?.id ?? "",
            assignees: [],
            assigneeIds: task.assigneeIDs,
            createdAt: Date(),
            startDate: Date(),
            dueDate: task.endDate,
            files: task.files,           // ✅ Hata 1 düzeltildi — [TaskFile] direkt atanıyor
            comments: [],
            number: tasks.count + 1
        )
        tasks.append(newTask)
        return newTask
    }

    func updateStatus(id: String, status: TaskStatus) async throws -> TaskItem {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw AppError.notFound
        }
        tasks[index].status = status
        return tasks[index]
    }

    func deleteTask(id: String) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        tasks.removeAll { $0.id == id }
    }

    func addAssignee(taskID: String, userID: String) async throws -> TaskItem {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else {
            throw AppError.notFound
        }
        if !tasks[index].assigneeIds.contains(userID) {
            tasks[index].assigneeIds.append(userID)
        }
        return tasks[index]
    }

    func removeAssignee(taskID: String, assigneeID: String) async throws -> TaskItem {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else {
            throw AppError.notFound
        }
        tasks[index].assignees.removeAll { $0.id == assigneeID }
        tasks[index].assigneeIds.removeAll { $0 == assigneeID }
        return tasks[index]
    }

    func addComment(taskID: String, text: String) async throws -> TaskComment {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let index = tasks.firstIndex(where: { $0.id == taskID }) else {
            throw AppError.notFound
        }
        let comment = TaskComment(
            id: UUID().uuidString,       // ✅ Hata 2 düzeltildi — String
            user: User.mockUser1,        // ✅ Hata 3 düzeltildi — User objesi
            text: text,                  // ✅ alan adı text (userName değil)
            date: Date()
        )
        tasks[index].comments.append(comment)
        return comment
    }
}

