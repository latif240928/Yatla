// UI/Components/DepartmentGroupCard.swift
//
// Sohbetler → Toparlar içinde görüntülenen kart. Karta dokunulduğunda,
// her üyenin diğer üyelerin mesajlarını görebildiği departman çapında
// bir grup sohbeti açılır.
import SwiftUI

struct DepartmentGroupCard: View {
    let department: Department
    let memberCount: Int
    let lastMessage: ChatMessage?
    var unreadCount: Int = 0
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryLight)
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.3.fill")
                        .font(AppFonts.aestetico(size: 22))
                        .foregroundColor(AppColors.primary)
                }
                .overlay(alignment: .topTrailing) {
                    if unreadCount > 0 {
                        Circle()
                            .fill(AppColors.error)
                            .frame(width: 10, height: 10)
                            .offset(x: 2, y: -2)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(department.name)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    if let last = lastMessage {
                        Text("\(last.sender.name): \(last.text)")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    } else {
                        Text("\(memberCount) ulanyjy")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if let last = lastMessage {
                        Text(AppDateFormatters.hourMinute.string(from: last.sentAt))
                            .font(AppFonts.caption2)
                            .foregroundColor(AppColors.textHint)
                    }
                    Text("\(memberCount)")
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textHint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.surfaceLight)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppColors.surface)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 12) {
        DepartmentGroupCard(
            department: Department(id: "dept-1", name: "iOS Team"),
            memberCount: 5,
            lastMessage: ChatMessage(
                id: "1",
                sender: User(id: "u1", name: "Latif", phone: ""),
                text: "Bugün build çalıştı mı?",
                sentAt: Date()
            ),
            unreadCount: 2,
            onTap: {}
        )
        DepartmentGroupCard(
            department: Department(id: "dept-2", name: "Backend"),
            memberCount: 3,
            lastMessage: nil,
            onTap: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
