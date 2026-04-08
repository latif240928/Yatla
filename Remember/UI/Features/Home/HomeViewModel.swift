// UI/Features/Home/HomeViewModel.swift
import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published
    @Published var tasks: [TaskItem] = []
    @Published var departments: [Department] = []
    @Published var selectedDepartment: Department? = nil
    @Published var selectedStatus: TaskStatus? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Sheet kontrollary
    @Published var showDepartmentSheet: Bool = false
    @Published var showStatusSheet: Bool = false

    // MARK: - Current User backend geleson auth den alynar
    let currentUser = CurrentUserProvider.user

    // MARK: - Use Cases
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

    // MARK: - Computed
    var filteredTasks: [TaskItem] {
        var result = tasks

        if let dept = selectedDepartment {
            if dept.id == "sahsy" {
                // Şahsy tasklar
                result = result.filter { $0.departmentId == "sahsy" }
            } else {
                // Saylanan department + mana berilen
                result = result.filter {
                    $0.departmentId == dept.id &&
                    $0.assigneeIds.contains(currentUser.id)
                }
            }
        } else {
            // Hemmesi
            result = result.filter {
                $0.assigneeIds.contains(currentUser.id)
            }
        }

        if let status = selectedStatus {
            result = result.filter { $0.status == status }
        }

        return result
    }

    // MARK: - Actions
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

