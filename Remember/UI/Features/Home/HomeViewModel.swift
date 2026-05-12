// Ana sekme: görev listesi, departman ve durum süzgeçleri.
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Yayınlanan durum
    @Published var tasks: [TaskItem] = []
    @Published var departments: [Department] = []
    @Published var selectedDepartment: Department? = nil
    @Published var selectedStatus: TaskStatus? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Sayfa örtüleri (sheet)
    @Published var showDepartmentSheet: Bool = false
    @Published var showStatusSheet: Bool = false

    // MARK: - Oturum kullanıcısı (kimlik doğrulama sonrası sunucudan gelir)
    let currentUser = CurrentUserProvider.user

    // MARK: - Use case'ler
    private let getTasksUseCase: GetTasksUseCase
    private let getDepartmentsUseCase: GetDepartmentsUseCase
    private let createDepartmentUseCase: CreateDepartmentUseCase
    private let updateTaskStatusUseCase: UpdateTaskStatusUseCase

    @MainActor
    init(
        getTasksUseCase: GetTasksUseCase? = nil,
        getDepartmentsUseCase: GetDepartmentsUseCase? = nil,
        createDepartmentUseCase: CreateDepartmentUseCase? = nil,
        updateTaskStatusUseCase: UpdateTaskStatusUseCase? = nil
    ) {
        self.getTasksUseCase = getTasksUseCase ?? DIContainer.shared.getTasksUseCase
        self.getDepartmentsUseCase = getDepartmentsUseCase ?? DIContainer.shared.getDepartmentsUseCase
        self.createDepartmentUseCase = createDepartmentUseCase ?? DIContainer.shared.createDepartmentUseCase
        self.updateTaskStatusUseCase = updateTaskStatusUseCase ?? DIContainer.shared.updateTaskStatusUseCase
    }

    // MARK: - Hesaplanmış özellikler
    /// Mevcut kullanıcının "dahil olduğu" görevler — ya oluşturucusu ya da
    /// atanan kişi. Bu, ana sekme ("Ýumuşlar") için kullanıcı beklentisine
    /// uygundur: kabul edilen bir teklif (oluşturucunun başka biri olduğu)
    /// kullanıcının kendi oluşturduğu görevlerle birlikte burada görünür.
    var filteredTasks: [TaskItem] {
        var result = tasks.filter {
            $0.creatorId == currentUser.id ||
            $0.assigneeIds.contains(currentUser.id)
        }

        if let dept = selectedDepartment {
            if dept.id == "sahsy" {
                result = result.filter { $0.departmentId == "sahsy" }
            } else {
                result = result.filter { $0.departmentId == dept.id }
            }
        }

        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        return result
    }

    // MARK: - İşlemler
    func loadData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                async let tasksResult = getTasksUseCase.execute()
                async let deptsResult = getDepartmentsUseCase.execute()
                self.tasks = try await tasksResult
                self.departments = try await deptsResult
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    func createDepartment(name: String) async {
        do {
            let dept = try await createDepartmentUseCase.execute(name: name)
            departments.append(dept)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateTaskStatus(taskId: String, status: TaskStatus) {
        Task {
            do {
                let updated = try await updateTaskStatusUseCase.execute(id: taskId, status: status)
                if let index = tasks.firstIndex(where: { $0.id == updated.id }) {
                    tasks[index] = updated
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

