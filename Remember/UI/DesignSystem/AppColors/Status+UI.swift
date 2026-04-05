// UI/DesignSystem/AppColors/Status+UI.swift
import SwiftUI

// TaskStatus -> SwiftUI Color 
extension TaskStatus {
    /// Status SwiftUI renki
    var color: Color {
        Color(hex: colorHex)
    }

    /// Status renk
    var backgroundColor: Color {
        color.opacity(0.15)
    }

    /// Status at
    var iconName: String {
        switch self {
        case .waiting:    return "clock.fill"
        case .inProgress: return "arrow.triangle.2.circlepath"
        case .completed:  return "checkmark.circle.fill"
        case .cancelled:  return "xmark.circle.fill"
        case .returned:   return "arrow.uturn.backward.circle.fill"
        }
    }
}
