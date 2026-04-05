
// UI/Features/Users/Components/UserCard.swift
import SwiftUI

struct UserCard: View {
    let user: User
    let stats: UserTaskStats?
    var onDelete: (() -> Void)?
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {

                // Header: Avatar + at + pozmak
                HStack(spacing: 12) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.2))
                            .frame(width: 48, height: 48)
                        Text(user.name.prefix(2).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppColors.primary)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(user.name)
                            .font(AppFonts.headline)
                            .foregroundColor(.white)
                        Text(user.phone)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    Spacer()

                    Button(action: { onDelete?() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.error)
                            .frame(width: 36, height: 36)
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(8)
                    }
                }

                Divider().background(AppColors.divider)

                // footer: Department + statistikalar
                HStack {
                    Text(user.departmentIds.first ?? "—")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    if let stats = stats {
                        HStack(spacing: 12) {
                            statLabel(value: stats.assignedTaskCount, label: "tasks", color: AppColors.primary)
                            statLabel(value: stats.completedTaskCount, label: "completed", color: AppColors.statusDone)
                            statLabel(value: stats.pendingTaskCount, label: "active", color: AppColors.warning)
                        }
                    }
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 14).fill(AppColors.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColors.divider, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func statLabel(value: Int, label: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Text("\(value)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColors.textHint)
        }
    }
}

#Preview {
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
        onDelete: {
            print("Delete tapped")
        },
        onTap: {
            print("Card tapped")
        }
    )
    .padding()
    
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
        onDelete: {
            print("Delete tapped")
        },
        onTap: {
            print("Card tapped")
        }
    )
    .padding()
   
}
