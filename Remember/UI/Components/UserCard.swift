// UI/Features/Users/Components/UserCard.swift
import SwiftUI

struct UserCard: View {
    let user: User
    let stats: UserTaskStats?
    var departments: [Department] = []
    var onDelete: (() -> Void)?
    var onTap: (() -> Void)?
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    /// Kullanıcının ait olduğu tüm departmanları birleştirir: örn. "iOS Team, Backend".
    /// Hiçbir departman eşleşmezse "—" döner.
    private var departmentLabel: String {
        let names = user.departmentIds.compactMap { id in
            departments.first(where: { $0.id == id })?.name
        }
        return names.isEmpty ? "—" : names.joined(separator: ", ")
    }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(AppColors.primaryLight)
                            .frame(width: 48, height: 48)
                        Text(user.name.prefix(2).uppercased())
                            .font(AppFonts.aestetico(size: 16, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.name)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Text(user.phone)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Button(action: { onDelete?() }) {
                        Image(systemName: "trash")
                            .font(AppFonts.aestetico(size: 16, weight: .bold))
                            .foregroundColor(AppColors.error)
                            .frame(width: 32, height: 32)
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.error.opacity(0.2), lineWidth: 1)
                            )
                    }
                }

                Rectangle()
                    .fill(AppColors.divider)
                    .frame(height: 1)

                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "briefcase.fill")
                            .font(AppFonts.aestetico(size: 11))
                            .foregroundColor(AppColors.primary)
                        Text(departmentLabel)
                            .font(AppFonts.caption3)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    if let stats = stats {
                        HStack(spacing: 12) {
                            statLabel(value: stats.assignedTaskCount, label: L10n.string(.userCardTasks, language: lang), color: AppColors.primary)
                            statLabel(value: stats.completedTaskCount, label: L10n.string(.userCardCompleted, language: lang), color: AppColors.success)
                            statLabel(value: stats.pendingTaskCount, label: L10n.string(.userCardActive, language: lang), color: AppColors.warning)
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }

    private func statLabel(value: Int, label: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Text("\(value)")
                .font(AppFonts.caption1)
                .foregroundColor(color)
            Text(label)
                .font(AppFonts.caption2)
                .foregroundColor(AppColors.textHint)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        UserCard(
            user: User(
                id: "1",
                name: "Abdullatif Durdybayew",
                phone: "+993 62445524",
                departmentIds: ["iOS Team"]
            ),
            stats: UserTaskStats(
                userId: "user-1", assignedTaskCount: 12,
                completedTaskCount: 8,
                pendingTaskCount: 4
            ),
            onDelete: { print("Delete tapped") },
            onTap: { print("Card tapped") }
        )
        .padding(.horizontal)
        
        UserCard(
            user: User(
                id: "2",
                name: "Haknazar Haljanow",
                phone: "+993 XXXXXXXX",
                departmentIds: ["iOS Team"]
            ),
            stats: UserTaskStats(
                userId: "user-2", assignedTaskCount: 999,
                completedTaskCount: 999,
                pendingTaskCount: 999
            ),
            onDelete: { print("Delete tapped") },
            onTap: { print("Card tapped") }
        )
        .padding(.horizontal)
    }
    .background(AppColors.background)
}
