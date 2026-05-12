// TaskUseCases.swift
import Foundation

final class GetTasksUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) { self.repository = repository }

    func execute() async throws -> [TaskItem] {
        try await repository.getTasks()
    }
}

final class CreateTaskUseCase {
    private let repository: TaskRepository
    private let notificationService: NotificationService

    init(repository: TaskRepository, notificationService: NotificationService) {
        self.repository = repository
        self.notificationService = notificationService
    }

    @MainActor
    convenience init(repository: TaskRepository) {
        self.init(repository: repository, notificationService: DIContainer.shared.notificationService)
    }

    func execute(_ task: CreateTask) async throws -> TaskItem {
        guard task.isValid else {
            throw AppError.emptyField
        }

        let createdTask = try await repository.createTask(task)

        // Görev hatırlatması zamanla
        do {
            try await notificationService.scheduleTaskReminder(
                taskId: createdTask.id,
                taskTitle: createdTask.title,
                dueDate: createdTask.dueDate
            )
        } catch {
            print("Failed to schedule task reminder: \(error)")
            // Hatayı propagate etme, görev başarıyla oluşturuldu
        }

        return createdTask
    }
}

final class UpdateTaskStatusUseCase {
    private let repository: TaskRepository
    private let notificationService: NotificationService

    init(repository: TaskRepository, notificationService: NotificationService) {
        self.repository = repository
        self.notificationService = notificationService
    }

    @MainActor
    convenience init(repository: TaskRepository) {
        self.init(repository: repository, notificationService: DIContainer.shared.notificationService)
    }

    func execute(id: String, status: TaskStatus) async throws -> TaskItem {
        let updatedTask = try await repository.updateStatus(id: id, status: status)

        // Eğer görev tamamlandıysa hatırlatmayı iptal et
        if status == .completed || status == .cancelled {
            await notificationService.cancelTaskReminder(taskId: id)
        } else {
            // Durum değiştiyse hatırlatmayı yeniden zamanla
            do {
                try await notificationService.scheduleTaskReminder(
                    taskId: updatedTask.id,
                    taskTitle: updatedTask.title,
                    dueDate: updatedTask.dueDate
                )
            } catch {
                print("Failed to reschedule task reminder: \(error)")
            }
        }

        return updatedTask
    }
}

final class DeleteTaskUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) { self.repository = repository }

    func execute(id: String) async throws {
        try await repository.deleteTask(id: id)
    }
}

final class AddAssigneeUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) { self.repository = repository }

    func execute(taskID: String, userID: String) async throws -> TaskItem {
        try await repository.addAssignee(taskID: taskID, userID: userID)
    }
}

final class RemoveAssigneeUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) { self.repository = repository }

    func execute(taskID: String, assigneeID: String) async throws -> TaskItem {
        try await repository.removeAssignee(taskID: taskID, assigneeID: assigneeID)
    }
}

final class AddCommentUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) { self.repository = repository }

    func execute(taskID: String, text: String) async throws -> TaskComment {
        guard !text.isEmpty else {
            throw AppError.emptyField
        }
        return try await repository.addComment(taskID: taskID, text: text)
    }
}

