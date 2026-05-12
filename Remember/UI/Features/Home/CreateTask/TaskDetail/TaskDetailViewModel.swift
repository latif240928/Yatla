//
//  TaskDetailViewModel.swift
//  Remember
//
//  Oluşturan: Latif — 08.04.2026.
//
//  Görev detayı: dosya yükleme ve "Barlanmaly işler" onay akışı durumu.
//

import SwiftUI
import Combine

/// "Barlanmaly işler" sekmesinde tek bir atananın gönderdiği işin yaşam döngüsü.
enum BarlanmalyStage: Equatable {
    case pending
    case accepted
    case returned(comment: String)
}

@MainActor
final class TaskDetailViewModel: ObservableObject {

    // MARK: - Yayınlanan durum
    @Published var task: TaskItem
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showFilePicker: Bool = false
    @Published var uploadedFiles: [TaskFile] = []
    @Published var isUploadingFile: Bool = false

    /// İnceleme sekmesinde atanan başına durum. Anahtar: `TaskAssignee.id`.
    @Published var barlanmalyStages: [String: BarlanmalyStage] = [:]

    /// Doluysa bu atan için "geri çevir + yorum" sayfası gösterilir.
    @Published var returningAssignee: TaskAssignee? = nil

    // MARK: - Bağımlılıklar
    private let uploadTaskFileUseCase: UploadTaskFileUseCase

    let currentUser = CurrentUserProvider.user

    // MARK: - Kurulum (DIContainer)
    init(task: TaskItem) {
        self.task = task
        self.uploadedFiles = task.files
        self.uploadTaskFileUseCase = DIContainer.shared.uploadTaskFileUseCase
    }

    // MARK: - Test / Önizleme kurulumu
    init(
        task: TaskItem,
        uploadTaskFileUseCase: UploadTaskFileUseCase
    ) {
        self.task = task
        self.uploadedFiles = task.files
        self.uploadTaskFileUseCase = uploadTaskFileUseCase
    }

    // MARK: - Onay sekmesi eylemleri

    func stage(for assignee: TaskAssignee) -> BarlanmalyStage {
        barlanmalyStages[assignee.id] ?? .pending
    }

    func acceptAssignee(_ assignee: TaskAssignee) {
        barlanmalyStages[assignee.id] = .accepted
        // TODO: Backend hazır olunca `UpdateAssigneeStatusUseCase` ile değiştir.
    }

    /// "Yorumla geri çevir" adım 1: sayfayı göster.
    func requestReturn(_ assignee: TaskAssignee) {
        returningAssignee = assignee
    }

    /// Adım 2: kullanıcı yorum yazıp "Iber"e bastığında.
    func confirmReturn(_ assignee: TaskAssignee, comment: String) {
        let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Red nedeni olarak yorumu geçmişe ekle.
        let entry = TaskComment(
            id: UUID().uuidString,
            user: currentUser,
            text: trimmed,
            date: Date()
        )
        task.comments.append(entry)
        barlanmalyStages[assignee.id] = .returned(comment: trimmed)
        returningAssignee = nil
        // TODO: Uç nokta hazır olunca `TaskRepository` ile kalıcı yaz.
    }

    func cancelReturn() {
        returningAssignee = nil
    }

    // MARK: - Dosya yükleme
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

    // MARK: - Görevi iptal et
    func cancelTask(onSuccess: @escaping () -> Void) {
        // İleride CancelTaskUseCase bağlanabilir.
        onSuccess()
    }
}
