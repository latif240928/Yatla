// Data/DTO/DepartmentDTO.swift
//
// Mirror of `DepartmentResponse` in `openapi.json`:
// { "id": "...", "name": "...", "created_at": "..." }
import Foundation

struct DepartmentDTO: Codable {
    let id: String
    let name: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
    }

    func toDomain() -> Department {
        Department(id: id, name: name, createdAt: createdAt)
    }
}
