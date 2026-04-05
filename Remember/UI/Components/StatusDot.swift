// UI/Components/StatusBadge.swift
import SwiftUI

/// Task yagday badge i — kici tegelek
struct StatusBadge: View {
    let status: TaskStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(status.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(status.backgroundColor)
            )
    }
}

/// Yagday nokady — kici tegelek
struct StatusDot: View {
    let status: TaskStatus

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: 8, height: 8)
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(TaskStatus.allCases, id: \.self) { status in
            HStack {
                StatusDot(status: status)
                StatusBadge(status: status)
            }
        }
    }
    .padding()
    .background(AppColors.background)
}
