// UI/Features/CreateTasks/CreateTasksViewModel.swift
import SwiftUI
import Combine

@MainActor
final class CreateTasksViewModel: ObservableObject {

    @Published var tasks: [TaskItem] = []
    @Published var departments: [Department] = []
    @Published var selectedDepartment: Department? = nil
    @Published var showCreateTask: Bool = false
    @Published var showDepartmentPicker: Bool = false
    @Published var selectedTask: TaskItem? = nil

    private let getTasksUseCase: GetTasksUseCase
    private let getDepartmentsUseCase: GetDepartmentsUseCase

    let currentUserId = CurrentUserProvider.user.id

    init() {
        self.getTasksUseCase       = DIContainer.shared.getTasksUseCase
        self.getDepartmentsUseCase = DIContainer.shared.getDepartmentsUseCase
        loadData()
    }

    init(
        getTasksUseCase: GetTasksUseCase,
        getDepartmentsUseCase: GetDepartmentsUseCase
    ) {
        self.getTasksUseCase       = getTasksUseCase
        self.getDepartmentsUseCase = getDepartmentsUseCase
        loadData()
    }

    var filteredTasks: [TaskItem] {
        let myTasks = tasks.filter { $0.assigneeIds.contains(currentUserId) }
        guard let dept = selectedDepartment else { return myTasks }
        return myTasks.filter { $0.departmentId == dept.id }
    }

    func loadData() {
        Task {
            do {
                async let tasksResult = getTasksUseCase.execute()
                async let deptsResult = getDepartmentsUseCase.execute()
                self.tasks       = try await tasksResult
                self.departments = try await deptsResult
            } catch {
                print("CreateTasksViewModel error: \(error)")
            }
        }
    }

    //  Yeni task'ı network çağrısı olmadan direkt listeye ekle
    func addTask(_ task: TaskItem) {
        tasks.insert(task, at: 0)
    }

    func refresh() { loadData() }
}
