// UI/Features/CreateTask/CreateTaskViewModel.swift
import SwiftUI
import Combine
 
@MainActor
final class CreateTaskViewModel: ObservableObject {
 
    @Published var createTask: CreateTask = CreateTask()
    @Published var departments: [Department] = []
    @Published var allUsers: [User] = []
    @Published var selectedUsers: [User] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var newDepartmentName: String = ""
    @Published var showDepartmentPicker: Bool = false
    @Published var showUserPicker: Bool = false
 
    // MARK: - File
    @Published var selectedFiles: [URL] = []
    @Published var showFilePicker: Bool = false
 
    let currentUser = CurrentUserProvider.user
 
    private let createTaskUseCase: CreateTaskUseCase
    private let getDepartmentsUseCase: GetDepartmentsUseCase
    private let createDepartmentUseCase: CreateDepartmentUseCase
    private let getUsersUseCase: GetUsersUseCase
 
    init() {
        self.createTaskUseCase       = DIContainer.shared.createTaskUseCase
        self.getDepartmentsUseCase   = DIContainer.shared.getDepartmentsUseCase
        self.createDepartmentUseCase = DIContainer.shared.createDepartmentUseCase
        self.getUsersUseCase         = DIContainer.shared.getUsersUseCase
        loadData()
    }
 
    init(
        createTaskUseCase: CreateTaskUseCase,
        getDepartmentsUseCase: GetDepartmentsUseCase,
        createDepartmentUseCase: CreateDepartmentUseCase,
        getUsersUseCase: GetUsersUseCase
    ) {
        self.createTaskUseCase       = createTaskUseCase
        self.getDepartmentsUseCase   = getDepartmentsUseCase
        self.createDepartmentUseCase = createDepartmentUseCase
        self.getUsersUseCase         = getUsersUseCase
        loadData()
    }
 
    var isSahsy: Bool { createTask.department?.id == "sahsy" }
 
    func loadData() {
        Task {
            do {
                let depts = try await getDepartmentsUseCase.execute()
                self.departments = depts
                self.allUsers = await getUsersUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
 
    func addUser(_ user: User) {
        guard !selectedUsers.contains(where: { $0.id == user.id }) else { return }
        selectedUsers.append(user)
        createTask.assigneeIDs.append(user.id)
    }
 
    func removeUser(_ user: User) {
        selectedUsers.removeAll { $0.id == user.id }
        createTask.assigneeIDs.removeAll { $0 == user.id }
    }
 
    // MARK: - File işlemleri
    func addFile(_ url: URL) {
        guard !selectedFiles.contains(url) else { return }
        selectedFiles.append(url)
    }
 
    func removeFile(_ url: URL) {
        withAnimation {
            selectedFiles.removeAll { $0 == url }
        }
    }
 
    func addNewDepartment() {
        guard !newDepartmentName.isEmpty else { return }
        let name = newDepartmentName
        newDepartmentName = ""
        Task {
            do {
                let dept = try await createDepartmentUseCase.execute(name: name)
                departments.append(dept)
                createTask.department = dept
                showDepartmentPicker = false
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
 
    func createNewTask(onSuccess: @escaping () -> Void) {
        if isSahsy { createTask.assigneeIDs = [currentUser.id] }
        guard createTask.isValid else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                _ = try await createTaskUseCase.execute(createTask)
                isLoading = false
                onSuccess()
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
