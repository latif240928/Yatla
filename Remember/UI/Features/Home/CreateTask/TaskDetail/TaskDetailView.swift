import SwiftUI
import UniformTypeIdentifiers

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .mazmuny

    enum DetailTab: String, CaseIterable {
        case mazmuny   = "Işiň mazmuny"
        case barlanmaly = "Barlanmaly işler"
    }

    init(task: TaskItem) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(task: task))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Yokary bar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                            Text(viewModel.task.department)
                                .font(AppFonts.subheadline)
                        }
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: - Tab
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
                                .background(selectedTab == tab ? AppColors.surfaceLight : Color.clear)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(4)
                .background(AppColors.surface)
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                // MARK: - İçerik
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch selectedTab {
                        case .mazmuny:   mazmunyContent
                        case .barlanmaly: barlanmalyContent
                        }
                    }
                    .padding(20)
                }

                // MARK: - Sabit alt button
                if selectedTab == .mazmuny {
                    Button(action: {
                        viewModel.cancelTask { dismiss() }
                    }) {
                        Text("Işi ýatyrmak")
                            .font(AppFonts.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.error))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                }
            }

            // MARK: - Error toast
            if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text(error)
                        .font(AppFonts.caption1)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(AppColors.error.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                }
            }
        }
        .navigationBarHidden(true)
        // MARK: - File picker
        .fileImporter(
            isPresented: $viewModel.showFilePicker,
            allowedContentTypes: [.pdf, .image, .plainText, .data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    viewModel.uploadFile(url: url)
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Mazmuny Tab
    private var mazmunyContent: some View {
        VStack(alignment: .leading, spacing: 20) {

            // Mazmuny
            VStack(alignment: .leading, spacing: 6) {
                Text("Mazmuny")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                Text(viewModel.task.description.isEmpty ? "Beýany ýok" : viewModel.task.description)
                    .font(AppFonts.taskDescription)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }

            // MARK: - Seneler
            HStack(spacing: 12) {
                dateCard(title: "Başlanan güni",  value: formatDate(viewModel.task.startDate))
                dateCard(title: "Başlanan wagty", value: formatTime(viewModel.task.startDate))
            }
            HStack(spacing: 12) {
                dateCard(title: "Tamamlanmaly güni",  value: formatDate(viewModel.task.dueDate))
                dateCard(title: "Tamamlanmaly wagty", value: formatTime(viewModel.task.dueDate))
            }

            // MARK: - Degişli adamlar (read-only)
            VStack(alignment: .leading, spacing: 8) {
                Text("Degişli adamlar")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                if viewModel.task.assignees.isEmpty {
                    Text("Heniz adam goşulmady")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textHint)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                } else {
                    ForEach(viewModel.task.assignees) { assignee in
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(AppFonts.title1)
                                .foregroundColor(AppColors.primary)
                            Text(assignee.user.name)
                                .font(AppFonts.body)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                    }
                }
            }

            // MARK: - Faýllar
            VStack(alignment: .leading, spacing: 8) {
                Text("Faýl:")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                // Yüklenen dosyalar listesi
                ForEach(viewModel.uploadedFiles) { file in
                    HStack(spacing: 10) {
                        Image(systemName: fileIcon(for: file.format))
                            .foregroundColor(fileIconColor(for: file.format))
                            .font(.system(size: 20))
                        Text(file.name)
                            .font(AppFonts.body)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                        Button(action: { viewModel.removeFile(file) }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColors.textHint)
                                .frame(width: 28, height: 28)
                                .background(AppColors.surfaceAlt)
                                .cornerRadius(6)
                        }
                    }
                    .padding(12)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                }

                // Dosya ekle butonu
                Button(action: { viewModel.showFilePicker = true }) {
                    HStack {
                        if viewModel.isUploadingFile {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                                .scaleEffect(0.8)
                            Text("Ýüklenýär...")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            Text(viewModel.uploadedFiles.isEmpty ? "Faýly ýüklemek" : "Başga faýl goşmak")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "paperclip")
                            .foregroundColor(AppColors.primary)
                    }
                    .padding(14)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                }
                .disabled(viewModel.isUploadingFile)
            }
        }
    }

    // MARK: - Barlanmaly işler Tab
    private var barlanmalyContent: some View {
        VStack(spacing: 16) {
            if viewModel.task.assignees.isEmpty {
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
                ForEach(viewModel.task.assignees) { assignee in
                    BarlanmalyCard(assignee: assignee, task: viewModel.task)
                }
            }
        }
    }

    // MARK: - Helpers
    private func dateCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppFonts.body)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
    }

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

    private func fileIcon(for format: String) -> String {
        switch format.lowercased() {
        case "pdf":            return "doc.fill"
        case "jpg", "jpeg", "png": return "photo.fill"
        case "doc", "docx":    return "doc.text.fill"
        case "xls", "xlsx":    return "tablecells.fill"
        default:               return "doc.fill"
        }
    }

    private func fileIconColor(for format: String) -> Color {
        switch format.lowercased() {
        case "pdf":            return .red
        case "jpg", "jpeg", "png": return .blue
        case "doc", "docx":    return .cyan
        case "xls", "xlsx":    return .green
        default:               return AppColors.textHint
        }
    }
}

// MARK: - Barlanmaly Card
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

            // Kommentariýa
            VStack(alignment: .leading, spacing: 6) {
                Text("Kommentariýa:")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

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
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text("Kabul edildi")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.success)
                }
                .padding(.top, 4)
            } else if isRejected {
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
