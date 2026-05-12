// `TaskItemDTO.toDomain()` üzerinde ince yüz. Bazı eski ViewModel'ler hâlâ `TaskMapper.fromDTO(_:)` çağırır; yeni kod doğrudan DTO kullanmalıdır.
import Foundation

enum TaskMapper {
    static func fromDTO(_ dto: TaskItemDTO) -> TaskItem {
        dto.toDomain()
    }

    static func fromDTOArray(_ dtos: [TaskItemDTO]) -> [TaskItem] {
        dtos.map { fromDTO($0) }
    }
}
