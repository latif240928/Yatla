//
//  TaskStatus.swift
enum TaskStatus: String, CaseIterable, Hashable, Codable {
    case waiting    = "Garaşylýar"
    case inProgress = "Ýerine ýetirilýär"
    case completed  = "Tamamlandy"
    case cancelled  = "Ýatyryldy"
    case returned   = "Yzyna gaýtaryldy"
    

    // Her status yn renki — hex string, SwiftUI import yok!
    var colorHex: String {
        switch self {
        case .waiting:    return "#F59E0B"
        case .inProgress: return "#3B82F6"
        case .completed:  return "#10B981"
        case .cancelled:  return "#EF4444"
        case .returned:   return "#EF4444"
        }
    }

    // 
    var displayName: String { rawValue }
}
