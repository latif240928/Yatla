// UI/Components/CreatedTaskCard.swift
import SwiftUI

struct CreatedTaskCard: View {
    let task: TaskItem
    var onTap: (() -> Void)? = nil
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text(task.title)
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(AppFonts.aestetico(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.bottom, 12)

                Rectangle()
                    .fill(AppColors.primary)
                    .frame(height: 1)
                    .padding(.bottom, 12)

                Text(task.description.isEmpty ? L10n.string(.taskNoDescription, language: lang) : task.description)
                    .font(AppFonts.taskDescription)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .padding(.bottom, 14)

                if !task.assignees.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(task.assignees.prefix(3).enumerated()), id: \.element.id) { index, assignee in
                            HStack(spacing: 0) {
                                Text("\(index + 1). \(assignee.user.name)")
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal, 12)
                                
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
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textHint)
                        }
                    }
                    .padding(.bottom, 14)
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
                    .overlay(Capsule().stroke(AppColors.primary, lineWidth: 1))

                    Spacer()
                    
                    Text("\(task.number)")
                        .font(AppFonts.statusText)
                        .foregroundColor(AppColors.textPrimary)
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
        return "\(f.string(from: start)) - \(f.string(from: end))"
    }
}

#Preview {
    let previewTask = TaskItem(
        id: "1", title: "Önizleme görevi", description: "Açıklama",
        status: .inProgress, department: "UI", departmentId: "ui-1",
        assignees: [], assigneeIds: [],
        creatorId: "preview", createdAt: Date(), startDate: Date(),
        dueDate: Date().addingTimeInterval(86400 * 3),
        files: [], comments: [], number: 1
    )
    ScrollView {
        VStack(spacing: 16) {
            CreatedTaskCard(task: previewTask)
        }
        .padding(16)
    }
    .background(AppColors.background)
}
