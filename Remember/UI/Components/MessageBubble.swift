// UI/Features/Chats/Components/MessageBubble.swift
import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let isFromMe: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isFromMe { Spacer(minLength: 60) }

            if !isFromMe {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryLight)
                        .frame(width: 32, height: 32)
                    Text(message.sender.name.prefix(1))
                        .font(AppFonts.aestetico(size: 13, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }
            }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(AppFonts.body)
                    .foregroundColor(isFromMe ? AppColors.textInverse : AppColors.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                isFromMe
                                ? AppColors.primary
                                : AppColors.surface
                            )
                    )
                    .overlay(
                        isFromMe
                            ? nil
                            : RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.divider, lineWidth: 1)
                    )

                HStack(spacing: 4) {
                    Text(formatTime(message.sentAt))
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textHint)
                    if isFromMe {
                        Image(systemName: message.isRead ? "checkmark.circle.fill" : "checkmark")
                            .font(AppFonts.aestetico(size: 10))
                            .foregroundColor(message.isRead ? AppColors.primary : AppColors.textHint)
                    }
                }
            }

            if !isFromMe { Spacer(minLength: 60) }
        }
    }

    private func formatTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}
