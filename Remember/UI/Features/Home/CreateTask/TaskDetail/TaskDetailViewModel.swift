//
//  TaskDetailViewMOdel.swift
//  Remember
//
//  Created by Latif on 08.04.2026.
//

import SwiftUI
import Combine

@MainActor
final class TaskDetailViewModel: ObservableObject {

    // MARK: - Published
    @Published var task: TaskItem
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showFilePicker: Bool = false
    @Published var uploadedFiles: [TaskFile] = []
    @Published var isUploadingFile: Bool = false

    // MARK: - Dependencies
    private let uploadTaskFileUseCase: UploadTaskFileUseCase

    let currentUser = CurrentUserProvider.user

    // MARK: - Init (DI Container'dan)
    init(task: TaskItem) {
        self.task = task
        self.uploadedFiles = task.files
        self.uploadTaskFileUseCase = DIContainer.shared.uploadTaskFileUseCase
    }

    // MARK: - Test / Preview init
    init(
        task: TaskItem,
        uploadTaskFileUseCase: UploadTaskFileUseCase
    ) {
        self.task = task
        self.uploadedFiles = task.files
        self.uploadTaskFileUseCase = uploadTaskFileUseCase
    }

    // MARK: - File yükleme
    func uploadFile(url: URL) {
        isUploadingFile = true
        errorMessage = nil

        Task {
            do {
                // Security scoped resource — dosya izni
                let accessed = url.startAccessingSecurityScopedResource()
                defer { if accessed { url.stopAccessingSecurityScopedResource() } }

                let file = try await uploadTaskFileUseCase.execute(
                    taskId: task.id,
                    fileURL: url
                )
                uploadedFiles.append(file)
                isUploadingFile = false
            } catch {
                errorMessage = error.localizedDescription
                isUploadingFile = false
            }
        }
    }

    func removeFile(_ file: TaskFile) {
        withAnimation {
            uploadedFiles.removeAll { $0.id == file.id }
        }
    }

    // MARK: - Işi ýatyrmak (cancel task)
    func cancelTask(onSuccess: @escaping () -> Void) {
        // Buraya CancelTaskUseCase eklenebilir
        onSuccess()
    }
}
