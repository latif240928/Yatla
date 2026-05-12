// Data/Mappers/UserMapper.swift
import Foundation

enum UserMapper {
    static func fromDTO(_ dto: UserDTO) -> User {
        dto.toDomain()
    }

    static func fromDTOArray(_ dtos: [UserDTO]) -> [User] {
        dtos.map { fromDTO($0) }
    }
}
