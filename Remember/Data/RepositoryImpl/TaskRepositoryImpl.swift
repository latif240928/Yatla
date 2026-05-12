// Data/Repositories/TaskRepositoryImpl.swift
import Foundation

final class TaskRepositoryImpl: TaskRepository {

    private let userRepository: UserRepository
    private var tasks: [TaskItem] = TaskItem.createdMockList

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func getTasks() async throws -> [TaskItem] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return tasks
    }

    func addTask(_ task: TaskItem) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        // De-dupe by id so an accidental double-tap doesn't put two copies in.
        guard !tasks.contains(where: { $0.id == task.id }) else { return }
        tasks.insert(task, at: 0)
    }

    func createTask(_ task: CreateTask) async throws -> TaskItem {
        try await Task.sleep(nanoseconds: 500_000_000)

        let allUsers = await userRepository.getUsers()
        let dueDate = Self.mergeDate(task.endDate, time: task.endTime)

        let assignees: [TaskAssignee] = task.assigneeIDs.map { uid in
            let user = allUsers.first(where: { $0.id == uid })
                ?? User(id: uid, name: "Ulanyjy", phone: "", departmentIds: [])
            return TaskAssignee(id: "\(UUID().uuidString.prefix(8))-\(uid)", user: user, status: .waiting)
        }

        let newTask = TaskItem(
            id: UUID().uuidString,
            title: task.name,
            description: task.mazmuny,
            status: .waiting,
            department: task.department?.name ?? "",
            departmentId: task.department?.id ?? "",
            assignees: assignees,
            assigneeIds: task.assigneeIDs,
            creatorId: task.creatorId,
            createdAt: Date(),
            startDate: Date(),
            dueDate: dueDate,
            files: task.files,
            comments: [],
            number: tasks.count + 1
        )
        tasks.append(newTask)
        return newTask
    }

    private static func mergeDate(_ date: Date, time: Date) -> Date {
        let cal = Calendar.current
        var dc = cal.dateComponents([.year, .month, .day], from: date)
        let timePart = cal.dateComponents([.hour, .minute, .second], from: time)
        dc.hour = timePart.hour
        dc.minute = timePart.minute
        dc.second = timePart.second
        return cal.date(from: dc) ?? date
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
            id: UUID().uuidString,
            user: User.mockUser1,
            text: text,
            date: Date()
        )
        tasks[index].comments.append(comment)
        return comment
    }

    func uploadFile(taskId: String, fileURL: URL) async throws -> TaskFile {
        try await Task.sleep(nanoseconds: 200_000_000)
        let file = TaskFile(
            id: UUID().uuidString,
            name: fileURL.lastPathComponent,
            format: fileURL.pathExtension,
            url: fileURL.absoluteString
        )
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].files.append(file)
        }
        return file
    }
}
