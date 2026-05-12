// UI/Components/TaskCard.swift
import SwiftUI

struct TaskCard: View {
    let task: TaskItem
    var onTap: (() -> Void)? = nil
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text(task.title)
                        .font(AppFonts.aestetico(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: task.status.colorHex))
                            .frame(width: 10, height: 10)
                        Text(task.status.displayName(language: lang))
                            .font(AppFonts.aestetico(size: 15))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
                .padding(.bottom, 10)

                Text(task.description.isEmpty ? L10n.string(.taskNoDescription, language: lang) : task.description)
                    .font(AppFonts.taskDescription)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .padding(.bottom, 12)

                if !task.assignees.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: -8) {
                            ForEach(Array(task.assignees.prefix(5).enumerated()), id: \.element.id) { _, assignee in
                                ZStack {
                                    Circle()
                                        .stroke(AppColors.primary, lineWidth: 2)
                                        .background(Circle().fill(AppColors.surfaceAlt))
                                        .frame(width: 34, height: 34)
                                    Text(String(assignee.user.name.prefix(1)).uppercased())
                                        .font(AppFonts.aestetico(size: 16, weight: .bold))
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            
                            if task.assignees.count > 5 {
                                Text("+\(task.assignees.count - 5)")
                                    .font(AppFonts.aestetico(size: 11, weight: .semibold))
                                    .foregroundColor(AppColors.textHint)
                                    .padding(.leading, 6)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(task.assignees.prefix(3).enumerated()), id: \.element.id) { index, assignee in
                                HStack(spacing: 8) {
                                    Text("\(index + 1) - \(assignee.user.name)")
                                        .font(AppFonts.caption1)
                                        .foregroundColor(AppColors.textSecondary)
                                    
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color(hex: assignee.status.colorHex))
                                            .frame(width: 8, height: 8)
                                        Text(assignee.status.displayName(language: lang))
                                            .font(AppFonts.caption1)
                                            .foregroundColor(Color(hex: assignee.status.colorHex))
                                    }
                                }
                            }
                            if task.assignees.count > 3 {
                                Text("+\(task.assignees.count - 3) adam")
                                    .font(AppFonts.caption2)
                                    .foregroundColor(AppColors.textHint)
                            }
                        }
                    }
                    .padding(.bottom, 12)
                }

                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(AppFonts.aestetico(size: 12))
                            .foregroundColor(AppColors.primary)
                        Text(formatDateRange(start: task.startDate, end: task.dueDate))
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(Capsule().stroke(AppColors.primary.opacity(0.6), lineWidth: 1.5))

                    Spacer()

                    Text("\(task.number)")
                        .font(AppFonts.statusText)
                        .foregroundColor(AppColors.textHint)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
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

    private func formatDateRange(start: Date, end: Date) -> String {
        let f = AppDateFormatters.dayMonthYearDot
        return "\(f.string(from: start))  -  \(f.string(from: end))"
    }
}

struct TaskCardExpanded: View {
    let task: TaskItem
    var onTap: (() -> Void)? = nil
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text(task.title)
                        .font(AppFonts.aestetico(size: 20, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                    Spacer()
                    StatusBadge(status: task.status)
                }
                .padding(.bottom, 10)

                Rectangle()
                    .fill(AppColors.divider)
                    .frame(height: 1)
                    .padding(.bottom, 10)

                Text(task.description.isEmpty ? L10n.string(.taskNoDescription, language: lang) : task.description)
                    .font(AppFonts.taskDescription)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .padding(.bottom, 10)

                if !task.assignees.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(task.assignees.prefix(3).enumerated()), id: \.element.id) { index, assignee in
                            HStack(spacing: 8) {
                                Text("\(index + 1) - \(assignee.user.name)")
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                StatusBadge(status: assignee.status)
                            }
                        }
                        if task.assignees.count > 3 {
                            Text("+\(task.assignees.count - 3) adam")
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textHint)
                        }
                    }
                    .padding(.bottom, 10)
                }

                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(AppFonts.aestetico(size: 12))
                            .foregroundColor(AppColors.primary)
                        Text(formatDateRange(start: task.startDate, end: task.dueDate))
                            .font(AppFonts.aestetico(size: 12))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .overlay(Capsule().stroke(AppColors.primary, lineWidth: 1.5))

                    Spacer()

                    Text("\(task.number)")
                        .font(AppFonts.statusText)
                        .foregroundColor(AppColors.textHint)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
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

    private func formatDateRange(start: Date, end: Date) -> String {
        let f = AppDateFormatters.dayMonthYearDot
        return "\(f.string(from: start)) / \(f.string(from: end))"
    }
}

extension TaskItem {
    static let mockList: [TaskItem] = [
        TaskItem(
            id: "1",
            title: "Iconlary ýygnamaly",
            description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
            status: .waiting,
            department: "UI Design",
            departmentId: "ui-1",
            assignees: [
                .init(id: "1", user: User.mockUser1, status: .waiting)
            ],
            assigneeIds: ["mock-user-1"],
            creatorId: CurrentUserProvider.user.id,
            createdAt: Date(),
            startDate: Date(),
            dueDate: Date().addingTimeInterval(86400 * 3),
            files: [],
            comments: [],
            number: 1
        ),
        TaskItem(
            id: "2",
            title: "App Design System",
            description: "Design system components need to be updated according to new brand guidelines.",
            status: .inProgress,
            department: "UI Design",
            departmentId: "ui-1",
            assignees: [
                .init(id: "2", user: User.mockUser1, status: .inProgress)
            ],
            assigneeIds: ["mock-user-1"],
            creatorId: CurrentUserProvider.user.id,
            createdAt: Date(),
            startDate: Date(),
            dueDate: Date().addingTimeInterval(86400 * 5),
            files: [],
            comments: [],
            number: 2
        )
    ]
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            Text("Berlen işler kartı")
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TaskCard(task: TaskItem.mockList[0])
            TaskCard(task: TaskItem.mockList[1])

            Divider().background(AppColors.divider).padding(.vertical, 8)

            Text("İş döretmek kartı")
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            TaskCardExpanded(task: TaskItem.mockList[0])
            TaskCardExpanded(task: TaskItem.mockList[1])
        }
        .padding(16)
    }
    .background(AppColors.background)
}
