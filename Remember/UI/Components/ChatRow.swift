// UI/Features/Chats/Components/ChatRowView.swift
import SwiftUI

struct ChatRowView: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 52, height: 52)
                Text(chat.participant.name.prefix(2).uppercased())
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
            .overlay(alignment: .topTrailing) {
                if chat.unreadCount > 0 {
                    Circle()
                        .fill(AppColors.error)
                        .frame(width: 10, height: 10)
                        .offset(x: 2, y: -2)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.participant.name)
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                Text(chat.lastMessage?.text ?? "")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(formatTime(chat.lastMessage?.sentAt ?? Date()))
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
                if chat.isMuted {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textHint)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.surface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.divider, lineWidth: 1))
    }

    private func formatTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}
