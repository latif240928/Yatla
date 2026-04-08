import Foundation

protocol UploadTaskFileUseCase {
    func execute(taskId: String, fileURL: URL) async throws -> TaskFile
}

final class UploadTaskFileUseCaseImpl: UploadTaskFileUseCase {
    private let taskRepository: TaskRepository

    init(taskRepository: TaskRepository) {
        self.taskRepository = taskRepository
    }

    func execute(taskId: String, fileURL: URL) async throws -> TaskFile {
        return try await taskRepository.uploadFile(taskId: taskId, fileURL: fileURL)
    }
}
