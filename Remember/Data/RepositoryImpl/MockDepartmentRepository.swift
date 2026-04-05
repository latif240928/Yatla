// Data/RepositoryImpl/MockDepartmentRepository.swift
import Foundation

final class MockDepartmentRepository: DepartmentRepository {

    private var departments: [Department] = [
        Department(id: "dept-1", name: "Dowletli Nesibe"),
        Department(id: "dept-2", name: "UI Design"),
        Department(id: "dept-3", name: "Frontend"),
        Department(id: "dept-4", name: "Backend"),
        Department(id: "sahsy", name: "Şahsy"),   // ✅ Şahsy her zaman var
    ]

    func getDepartments() async throws -> [Department] {
        try await Task.sleep(nanoseconds: 200_000_000)
        return departments
    }

    func createDepartment(name: String) async throws -> Department {
        try await Task.sleep(nanoseconds: 300_000_000)
        let dept = Department(id: UUID().uuidString, name: name)
        departments.append(dept)
        return dept
    }

    func deleteDepartment(id: String) async throws {
        departments.removeAll { $0.id == id }
    }
}

enum MockDepartments {
    static let all: [Department] = [
        Department(id: "all", name: "Ähli bölümler"),  // ✅ "Tümü" seçeneği
        Department(id: "dept-1", name: "Dowletli Nesibe"),
        Department(id: "dept-2", name: "UI Design"),
        Department(id: "dept-3", name: "Frontend"),
        Department(id: "dept-4", name: "Backend"),
        Department(id: "sahsy", name: "Şahsy"),
    ]
}
