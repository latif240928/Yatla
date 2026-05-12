// Data/Mappers/TaskOfferMapper.swift
import Foundation

enum TaskOfferMapper {
    static func fromDTO(_ dto: TaskOfferDTO) -> TaskOffer {
        dto.toDomain()
    }

    static func fromDTOArray(_ dtos: [TaskOfferDTO]) -> [TaskOffer] {
        dtos.map { fromDTO($0) }
    }
}
