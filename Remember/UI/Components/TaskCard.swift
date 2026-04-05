// UI/Components/TaskCard.swift
import SwiftUI

/// "Berlen işler" — HomeView
struct TaskCard: View {
    let task: TaskItem
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {

                // Header + nokat + status ady
                HStack(alignment: .center) {
                    Text(task.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: task.status.colorHex))
                            .frame(width: 8, height: 8)
                        Text(task.status.displayName)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 10)

                // Description italik
                Text(task.description.isEmpty ? "Mazmuny ýok" : task.description)
                    .font(.system(size: 13).italic())
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .padding(.bottom, 12)

                // footer: date + nomer
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.primary)
                        Text(formatDateRange(start: task.startDate, end: task.dueDate))
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(Capsule().stroke(AppColors.primary.opacity(0.6), lineWidth: 1))

                    Spacer()

                    Text("\(task.number)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.textHint)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(AppColors.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.primary.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func formatDateRange(start: Date, end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy'r'"
        return "\(fmt.string(from: start)) / \(fmt.string(from: end))"
    }
}

/// "İş döretmek" bölümündeki task kardy — assignee listi + status bilen
struct TaskCardExpanded: View {
    let task: TaskItem
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {

                // Header + status badge
                HStack(alignment: .center) {
                    Text(task.title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Spacer()
                    StatusBadge(status: task.status)
                }
                .padding(.bottom, 10)

                // Gok divider
                Rectangle()
                    .fill(AppColors.primary.opacity(0.3))
                    .frame(height: 1)
                    .padding(.bottom, 10)

                // Description
                Text(task.description.isEmpty ? "Mazmuny ýok" : task.description)
                    .font(.system(size: 13).italic())
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .padding(.bottom, 10)

                // Ulanyjylar + her birinin statusy
                if !task.assignees.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(task.assignees.prefix(3).enumerated()), id: \.element.id) { index, assignee in
                            HStack(spacing: 8) {
                                Text("\(index + 1). \(assignee.user.name)")
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

                // footer: date + nomer
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.primary)
                        Text(formatDateRange(start: task.startDate, end: task.dueDate))
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(Capsule().stroke(AppColors.primary.opacity(0.6), lineWidth: 1))

                    Spacer()

                    Text("\(task.number)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppColors.textHint)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(AppColors.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.primary.opacity(0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func formatDateRange(start: Date, end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy'r'"
        return "\(fmt.string(from: start)) / \(fmt.string(from: end))"
    }
}

// MARK: - Mock (Preview için)
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
            createdAt: Date(),
            startDate: Date(),
            dueDate: Date().addingTimeInterval(86400 * 3),
            files: [],
            comments: [],
            number: 123
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
            createdAt: Date(),
            startDate: Date(),
            dueDate: Date().addingTimeInterval(86400 * 5),
            files: [],
            comments: [],
            number: 124
        )
    ]
}

// MARK: - Preview
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
    .preferredColorScheme(.dark)
}
