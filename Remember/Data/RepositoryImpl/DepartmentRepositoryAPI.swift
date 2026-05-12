// `openapi.json` içindeki `/api/v1/departments` uç noktalarının gerçek ağ uygulaması:
//
//   GET    /api/v1/departments              -> [DepartmentResponse]
//   POST   /api/v1/departments              -> DepartmentResponse  ({ name })
//   GET    /api/v1/departments/{id}         -> DepartmentResponse
//   DELETE /api/v1/departments/{id}         -> 200 OK
import Foundation

final class DepartmentRepositoryAPI: DepartmentRepository {
    private let network: NetworkService

    init(network: NetworkService = .shared) {
        self.network = network
    }

    func getDepartments() async throws -> [Department] {
        let dtos: [DepartmentDTO] = try await network.request(path: "/departments", method: .get)
        return dtos.map { $0.toDomain() }
    }

    func createDepartment(name: String) async throws -> Department {
        struct RequestBody: Encodable { let name: String }

        let dto: DepartmentDTO = try await network.request(
            path: "/departments",
            method: .post,
            bodyObject: RequestBody(name: name)
        )
        return dto.toDomain()
    }

    func deleteDepartment(id: String) async throws {
        _ = try await network.request(path: "/departments/\(id)", method: .delete) as EmptyResponseDTO
    }
}
