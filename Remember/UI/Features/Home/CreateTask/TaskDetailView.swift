// UI/Features/CreateTask/TaskDetailView.swift

import SwiftUI

/// Task  popup — task kartyna basanda acylyar
struct TaskDetailView: View {
    let task: TaskItem
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .mazmuny
    @State private var commentText: String = ""

    enum DetailTab: String, CaseIterable {
        case mazmuny = "Işiň mazmuny"
        case barlanmaly = "Barlanmaly işler"
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - yokary bar: yza cykmak + header
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text(task.department)
                                .font(AppFonts.subheadline)
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: - Tab saylayjy: Işiň mazmuny | Barlanmaly işler
                HStack(spacing: 0) {
                    ForEach(DetailTab.allCases, id: \.rawValue) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                        }) {
                            Text(tab.rawValue)
                                .font(AppFonts.subheadline)
                                .foregroundColor(selectedTab == tab ? .white : AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    selectedTab == tab
                                        ? AppColors.surfaceLight
                                        : Color.clear
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(4)
                .background(AppColors.surface)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: - İçindakiler
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch selectedTab {
                        case .mazmuny:
                            mazmunyContent
                        case .barlanmaly:
                            barlanmalyContent
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Mazmuny Tab
    private var mazmunyContent: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Mazmuny
            VStack(alignment: .leading, spacing: 6) {
                Text("Mazmuny")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                Text(task.description.isEmpty ? "Beýany ýok" : task.description)
                    .font(AppFonts.taskDescription)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
            }

            // MARK: - Seneler
            HStack(spacing: 12) {
                // Cep — baslanan wagty
                VStack(alignment: .leading, spacing: 6) {
                    Text("Başlanan güni")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    Text(formatDate(task.startDate))
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppColors.surface)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))

                // Sag — baslanan sagady
                VStack(alignment: .leading, spacing: 6) {
                    Text("Başlanan wagty")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    Text(formatTime(task.startDate))
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppColors.surface)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }

            HStack(spacing: 12) {
                // Cep — Gutaryan wagty
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tamamlanmaly güni")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    Text(formatDate(task.dueDate))
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppColors.surface)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))

                // Sag — Gutarys sagady
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tamamlanmaly wagty")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    Text(formatTime(task.dueDate))
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppColors.surface)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }

            // MARK: - Degişli adamlar
            VStack(alignment: .leading, spacing: 8) {
                Text("Degişli adamlar")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                if task.assignees.isEmpty {
                    Text("Heniz adam goşulmady")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textHint)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                } else {
                    ForEach(task.assignees) { (assignee: TaskAssignee) in
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(AppFonts.title1)
                                .foregroundColor(AppColors.primary)

                            Text(assignee.user.name)
                                .font(AppFonts.body)
                                .foregroundColor(.white)

                            Spacer()

                            Button(action: { /* Delete assignee */ }) {
                                Image(systemName: "trash")
                                    .font(AppFonts.taskDescription)
                                    .foregroundColor(AppColors.error)
                                    .frame(width: 32, height: 32)
                                    .background(AppColors.error.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                    }
                }

                // Täze adamy goşmak
                Button(action: { /* Add assignee */ }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(AppFonts.footnote)
                            .foregroundColor(AppColors.primary)
                        Text("Täze adamy goşmak")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.primary)
                        Spacer()
                    }
                    .padding(12)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
                }
            }

            // MARK: - Faýl
            VStack(alignment: .leading, spacing: 6) {
                Text("Faýl:")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                Button(action: { /* File upload */ }) {
                    HStack {
                        Text("Faýly ýüklemek")
                            .font(AppFonts.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Image(systemName: "paperclip")
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(14)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
                }
            }

            // MARK: - Action buttonlary
            HStack(spacing: 12) {
                Button(action: { /* Cancel task */ }) {
                    Text("Işi ýatyrmak")
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.error))
                }

                Button(action: { /* Go to chat */ }) {
                    Text("Çada geçmek")
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.surfaceLight))
                }
            }
        }
    }

    // MARK: - Barlanmaly işler Tab
    // ulanyjylar tamamlan isini ugradar, sen kabul ya da yzyna gaytaryp bilyan
    private var barlanmalyContent: some View {
        VStack(spacing: 16) {
            if task.assignees.isEmpty {
                VStack(spacing: 12) {
                    Spacer().frame(height: 40)
                    Image(systemName: "checklist")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textHint)
                    Text("Barlanmaly iş ýok")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ForEach(task.assignees) { (assignee: TaskAssignee) in
                    BarlanmalyCard(assignee: assignee, task: task)
                }
            }
        }
    }

    // MARK: - Helpers
   
    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "dd / MM / yyyy'ý'"
        return fmt.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        return fmt.string(from: date)
    }
}

// MARK: - Barlanmaly Card — her ulanyjy ucin ayratyn card`
struct BarlanmalyCard: View {
    let assignee: TaskAssignee
    let task: TaskItem

    @State private var isRejected: Bool = false
    @State private var isAccepted: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Ulanyjy ady + sene
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(assignee.user.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(task.department) / \(task.title.lowercased())")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text("2 sagat öň")
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
            }

            // Kommentariýa bölümü
            VStack(alignment: .leading, spacing: 6) {
                Text("Kommentariýa:")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                // Comment
                let comment = task.comments.first(where: { $0.user.id == assignee.user.id })
                Text(comment?.text ?? "Kommentariýa goşulmady")
                    .font(AppFonts.taskDescription)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(AppColors.surfaceAlt)
                    .cornerRadius(10)

            
                if let comment = comment {
                    HStack {
                        Spacer()
                        Text("\(comment.text.count)")
                            .font(AppFonts.caption2)
                            .foregroundColor(AppColors.textHint)
                    }
                }
            }

            // Faýllar
            VStack(alignment: .leading, spacing: 6) {
                Text("Faýllar:")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                // Mock fayl
                HStack(spacing: 10) {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.red)
                        .font(.system(size: 20))
                    Text("fayl.pdf")
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                    Spacer()
                    Text("4,5 mb")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textHint)
                    Button(action: { /* Open file */ }) {
                        Image(systemName: "paperclip")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(12)
                .background(AppColors.surfaceAlt)
                .cornerRadius(10)
            }

            // MARK: - Kabul / Red buttonlary
            if isAccepted {
                // Kabul edildi yagdayy
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text("Kabul edildi")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.success)
                }
                .padding(.top, 4)
            } else if isRejected {
                // Reddedildi yagdayy
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.error)
                    Text("Yzyna gaýtaryldy")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.error)
                    Spacer()
                    Button(action: { /* Delete */ }) {
                        Image(systemName: "trash")
                            .foregroundColor(AppColors.error)
                            .frame(width: 36, height: 36)
                            .background(AppColors.error.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            } else {
                // Karar berilmedik
                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation { isRejected = true }
                    }) {
                        Text("Yzyna gaýtarmak")
                            .font(AppFonts.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AppColors.error))
                    }

                    Button(action: {
                        withAnimation { isAccepted = true }
                    }) {
                        Text("Kabul etmek")
                            .font(AppFonts.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AppColors.success))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
        )
    }
}

