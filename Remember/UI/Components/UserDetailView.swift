// UI/Features/Users/Components/UserDetailView.swift
import SwiftUI

struct UserDetailView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: UserDetailTab = .berkidilen
    @State private var allTasks: [TaskItem] = []

    enum UserDetailTab: String, CaseIterable {
        case berkidilen = "Berkidilen işleri"
        case tabsyran = "Tabşyran işler"
    }

    var assignedTasks: [TaskItem] {
        allTasks.filter { $0.assigneeIds.contains(user.id) }
    }

    var submittedTasks: [TaskItem] {
        allTasks.filter {
            $0.assigneeIds.contains(user.id) && $0.status == .completed
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(AppFonts.aestetico(size: 14, weight: .semibold))
                            Text(user.name)
                                .font(AppFonts.subheadline)
                        }
                        .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()

                    Button(action: { /* Poz */ }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppColors.error)
                            .frame(width: 36, height: 36)
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.error.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                HStack(spacing: 0) {
                    ForEach(UserDetailTab.allCases, id: \.rawValue) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                        }) {
                            Text(tab.rawValue)
                                .font(AppFonts.subheadline)
                                .foregroundColor(selectedTab == tab ? AppColors.textPrimary : AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == tab ? AppColors.surfaceLight : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(4)
                .background(AppColors.surface)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        switch selectedTab {
                        case .berkidilen:
                            if assignedTasks.isEmpty {
                                emptyState(text: "Berilen iş ýok")
                            } else {
                                ForEach(assignedTasks) { task in
                                    CreatedTaskCard(task: task)
                                }
                            }
                        case .tabsyran:
                            if submittedTasks.isEmpty {
                                emptyState(text: "Tabşyran iş ýok")
                            } else {
                                ForEach(submittedTasks) { task in
                                    SubmittedTaskCard(task: task)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            if let tasks = try? await DIContainer.shared.taskRepository.getTasks() {
                allTasks = tasks
            }
        }
    }

    private func emptyState(text: String) -> some View {
        VStack(spacing: 12) {
            Spacer().frame(height: 40)
            Image(systemName: "tray")
                .font(AppFonts.aestetico(size: 48))
                .foregroundColor(AppColors.textHint)
            Text(text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SubmittedTaskCard: View {
    let task: TaskItem
    @State private var isAccepted: Bool = false
    @State private var isRejected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.assignees.first?.user.name ?? "")
                        .font(AppFonts.aestetico(size: 16, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(task.department) / \(task.title.lowercased())")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text(formatDate(task.dueDate))
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Kommentariýa:")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
                Text(task.description)
                    .font(AppFonts.taskDescription)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surfaceAlt)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Faýllar:")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
                HStack(spacing: 10) {
                    Image(systemName: "doc.fill")
                        .foregroundColor(AppColors.error)
                    Text("fayl.pdf")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Text("4,5 mb")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textHint)
                    Button(action: {}) {
                        Image(systemName: "paperclip")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(12)
                .background(AppColors.surfaceAlt)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
            }

            if isAccepted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text("Kabul edildi")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.success)
                }
            } else if isRejected {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.error)
                    Text("Yzyna gaýtaryldy")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.error)
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "trash")
                            .foregroundColor(AppColors.error)
                            .frame(width: 36, height: 36)
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.error.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            } else {
                HStack(spacing: 12) {
                    Button(action: { withAnimation { isRejected = true } }) {
                        Text("Yzyna gaýtarmak")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textInverse)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.error)
                            )
                    }
                    Button(action: { withAnimation { isAccepted = true } }) {
                        Text("Kabul etmek")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textInverse)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(AppColors.success)
                            )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.divider, lineWidth: 1)
        )
        .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 8, y: 4)
    }

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd.MM.yyyy'ý'"
        return fmt.string(from: date)
    }
}

private var previewUser: User {
    User(
        id: "1",
        name: "Abdullatif Durdybayew",
        phone: "+99361234567",
        departmentIds: ["iOS Team"]
    )
}

#Preview("User Detail") {
    NavigationStack {
        UserDetailView(user: previewUser)
    }
    .background(AppColors.background)
}
