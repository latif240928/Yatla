// Domain/Repositories/DepartmentRepository.swift

protocol DepartmentRepository {
    func getDepartments() async throws -> [Department]
    
    func createDepartment(name: String) async throws -> Department
    
    func deleteDepartment(id: String) async throws
}
