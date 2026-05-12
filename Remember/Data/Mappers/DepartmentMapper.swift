// Data/Mappers/DepartmentMapper.swift
import Foundation

enum DepartmentMapper {
    static func fromDTO(_ dto: DepartmentDTO) -> Department {
        dto.toDomain()
    }

    static func fromDTOArray(_ dtos: [DepartmentDTO]) -> [Department] {
        dtos.map { fromDTO($0) }
    }
}
