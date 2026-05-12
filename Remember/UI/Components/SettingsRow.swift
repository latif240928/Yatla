// UI/Components/SettingsRow.swift
import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(AppFonts.aestetico(size: 16))
                    .foregroundColor(color)
            }
            Text(title)
                .font(AppFonts.title3.bold())
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(AppFonts.aestetico(size: 15, weight: .semibold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.divider, lineWidth: 1)
        )
        .shadow(color: AppColors.shadowColor(opacity: 0.03), radius: 4, y: 2)
    }
}
