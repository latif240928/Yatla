// UI/Features/Chats/Components/GroupChatRowView.swift
import SwiftUI

struct GroupChatRowView: View {
    let group: GroupChat

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(AppColors.surfaceLight)
                    .frame(width: 52, height: 52)
                Image(systemName: "person.3.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 52, height: 52)

                if group.unreadCount > 0 {
                    Circle()
                        .fill(AppColors.error)
                        .frame(width: 10, height: 10)
                        .offset(x: 2, y: -2)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(group.department.name)
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                Text("\(group.members.count) people")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Text(formatTime(group.lastMessage?.sentAt ?? Date()))
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textHint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.divider, lineWidth: 1))
    }

    private func formatTime(_ date: Date) -> String {
        guard let _ = group.lastMessage else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}
