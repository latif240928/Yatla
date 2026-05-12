// UI/Features/Chats/Components/ChatRowView.swift
import SwiftUI

struct ChatRowView: View {
    let chat: Chat

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                AppColors.primaryLight,
                                AppColors.primaryLight.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                Text(chat.participant.name.prefix(2).uppercased())
                    .font(AppFonts.aestetico(size: 17, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
            .overlay(alignment: .topTrailing) {
                if chat.unreadCount > 0 {
                    ZStack {
                        Circle()
                            .fill(AppColors.error)
                            .frame(width: 18, height: 18)
                        Text("\(min(chat.unreadCount, 99))")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .overlay(
                        Circle().stroke(AppColors.surface, lineWidth: 2)
                    )
                    .offset(x: 4, y: -4)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(chat.participant.name)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Text(chat.lastMessage?.text ?? "Heniz habar ýok")
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                if let last = chat.lastMessage {
                    Text(AppDateFormatters.hourMinute.string(from: last.sentAt))
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textHint)
                }
                if chat.isMuted {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppColors.textHint)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        // Köşe yuvarlaklığı 20'den → 24'e çıkarıldı, böylece satırlar daha
        // yumuşak ve hap şeklinde görünüyor, özellikle yeni departman grubu kartlarının yanında.
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppColors.divider, lineWidth: 1)
        )
        .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 6, y: 2)
        .contentShape(RoundedRectangle(cornerRadius: 24))
    }
}
