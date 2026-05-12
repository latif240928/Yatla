// UI/Components/StatusBadge.swift
import SwiftUI

struct StatusBadge: View {
    let status: TaskStatus
    @EnvironmentObject private var container: DIContainer

    var body: some View {
        Text(status.displayName(language: container.appSettings.selectedLanguage))
            .font(AppFonts.aestetico(size: 11, weight: .semibold))
            .foregroundColor(status.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(status.backgroundColor.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(status.backgroundColor.opacity(0.3), lineWidth: 1)
            )
    }
}

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
