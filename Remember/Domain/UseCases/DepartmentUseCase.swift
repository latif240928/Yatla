//  DepartmentUseCase.swift
final class GetDepartmentsUseCase {
    private let repository: DepartmentRepository
    init(repository: DepartmentRepository) { self.repository = repository }

    func execute() async throws -> [Department] {
        try await repository.getDepartments()
    }
}

final class CreateDepartmentUseCase {
    private let repository: DepartmentRepository
    init(repository: DepartmentRepository) { self.repository = repository }

    func execute(name: String) async throws -> Department {
        guard !name.isEmpty else {
            throw AppError.emptyDepartment
        }
        return try await repository.createDepartment(name: name)
    }
}
