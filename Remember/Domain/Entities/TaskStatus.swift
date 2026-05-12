//
//  TaskStatus.swift
//
//  Sunucu kablo biçimi (`openapi.json` → `TaskStatus` enum):
//   "waiting" | "inProgress" | "completed" | "cancelled" | "returned"
//
//  `rawValue` Türkmençe tutulur çünkü `TaskStatus.displayName` ile doğrudan gösterilir.
//  Ağ ile konuşan kod mutlaka `backendWireValue` / `fromWire(_:)` kullanmalıdır.
enum TaskStatus: String, CaseIterable, Hashable, Codable {
    case waiting    = "Garaşylýar"
    case inProgress = "Ýerine ýetirilýär"
    case completed  = "Tamamlandy"
    case cancelled  = "Ýatyryldy"
    case returned   = "Yzyna gaýtaryldy"

    /// REST `PATCH …/tasks/:id/status?status=…` parametresi. Sunucu **camelCase** kullanır (`inProgress`), snake_case değil.
    var backendWireValue: String {
        switch self {
        case .waiting:    return "waiting"
        case .inProgress: return "inProgress"
        case .completed:  return "completed"
        case .cancelled:  return "cancelled"
        case .returned:   return "returned"
        }
    }

    /// Sunucudan gelen kablo stringini (veya önbellekteki eski varyantları) `TaskStatus`'a çevirir.
    static func fromWire(_ raw: String) -> TaskStatus {
        switch raw.lowercased() {
        case "waiting", "garaşylýar":
            return .waiting
        case "inprogress", "in_progress", "ýerine ýetirilýär":
            return .inProgress
        case "completed", "tamamlandy":
            return .completed
        case "cancelled", "canceled", "ýatyryldy":
            return .cancelled
        case "returned", "yzyna gaýtaryldy":
            return .returned
        default:
            return .waiting
        }
    }

    /// Duruma özel vurgu rengi — SwiftUI bağımlılığı olmasın diye hex string.
    var colorHex: String {
        switch self {
        case .waiting:    return "#F59E0B"
        case .inProgress: return "#3B82F6"
        case .completed:  return "#10B981"
        case .cancelled:  return "#EF4444"
        case .returned:   return "#EF4444"
        }
    }

    var displayName: String { rawValue }

    func displayName(language: Language) -> String {
        let key: L10n.Key
        switch self {
        case .waiting:    key = .statusWaiting
        case .inProgress: key = .statusInProgress
        case .completed:  key = .statusCompleted
        case .cancelled:  key = .statusCancelled
        case .returned:   key = .statusReturned
        }
        return L10n.string(key, language: language)
    }
}
