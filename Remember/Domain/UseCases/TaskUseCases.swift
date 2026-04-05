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
    init(repository: TaskRepository) { self.repository = repository }

    func execute(_ task: CreateTask) async throws -> TaskItem {
        guard task.isValid else {
            throw AppError.emptyField
        }
        return try await repository.createTask(task)
    }
}

final class UpdateTaskStatusUseCase {
    private let repository: TaskRepository
    init(repository: TaskRepository) { self.repository = repository }

    func execute(id: String, status: TaskStatus) async throws -> TaskItem {
        try await repository.updateStatus(id: id, status: status)
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


