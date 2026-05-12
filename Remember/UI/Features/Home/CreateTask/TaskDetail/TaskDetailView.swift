// Görev detay ekranı: özet / onay sekmeleri, dosya yükleme ve geri bildirim akışı.
import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    @EnvironmentObject private var container: DIContainer
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: DetailTab = .mazmuny
    @State private var pickedPhotoItems: [PhotosPickerItem] = []

    private var lang: Language { container.appSettings.selectedLanguage }

    enum DetailTab: String, CaseIterable {
        case mazmuny   = "mazmuny"
        case barlanmaly = "barlanmaly"
    }

    init(task: TaskItem) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(task: task))
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - Üst çubuk
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(AppFonts.aestetico(size: 14, weight: .semibold))
                            Text(viewModel.task.department)
                                .font(AppFonts.subheadline)
                        }
                        .foregroundColor(AppColors.textPrimary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // MARK: - Sekmeler
                HStack(spacing: 0) {
                    ForEach(DetailTab.allCases, id: \.rawValue) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                        }) {
                            Text(tab == .mazmuny ? L10n.string(.taskContentTab, language: lang) : L10n.string(.taskReviewTab, language: lang))
                                .font(AppFonts.subheadline)
                                .foregroundColor(selectedTab == tab ? AppColors.textPrimary : AppColors.textSecondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedTab == tab ? AppColors.surfaceLight : Color.clear)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(4)
                .background(AppColors.surface)
                .cornerRadius(16)
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

                // MARK: - Sabit alt düğme (işi iptal)
                if selectedTab == .mazmuny {
                    Button(action: {
                        viewModel.cancelTask { dismiss() }
                    }) {
                        Text(L10n.string(.taskCancelTask, language: lang))
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

            // MARK: - Geçici hata bandı
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
        // MARK: - Dosya seçici
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
        // MARK: - "Yzyna gaýtarmak" yorum sayfası
        .sheet(item: $viewModel.returningAssignee) { assignee in
            ReturnTaskCommentSheet(
                assigneeName: assignee.user.name,
                onCancel: { viewModel.cancelReturn() },
                onSend: { comment in viewModel.confirmReturn(assignee, comment: comment) }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Mazmuny sekmesi (görev özeti)
    private var mazmunyContent: some View {
        VStack(alignment: .leading, spacing: 20) {

            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.string(.taskContent, language: lang))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textPrimary)

                Text(viewModel.task.description.isEmpty ? L10n.string(.taskNoDescription, language: lang) : viewModel.task.description)
                    .font(AppFonts.taskDescription)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }

            // MARK: - Tarih kartları
            HStack(spacing: 12) {
                dateCard(title: L10n.string(.taskStartDate, language: lang),  value: formatDate(viewModel.task.startDate))
                dateCard(title: L10n.string(.taskStartTime, language: lang), value: formatTime(viewModel.task.startDate))
            }
            HStack(spacing: 12) {
                dateCard(title: L10n.string(.taskDueDate, language: lang),  value: formatDate(viewModel.task.dueDate))
                dateCard(title: L10n.string(.taskDueTime, language: lang), value: formatTime(viewModel.task.dueDate))
            }

            // MARK: - Atananlar (salt okunur)
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.string(.taskAssignees, language: lang))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textPrimary)

                if viewModel.task.assignees.isEmpty {
                    Text(L10n.string(.taskNoAssignees, language: lang))
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
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(12)
                        .background(AppColors.surfaceAlt)
                        .cornerRadius(16)
                    }
                }
            }

            // MARK: - Dosyalar
            VStack(alignment: .leading, spacing: 8) {
                Text("\(L10n.string(.taskFile, language: lang)):")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                // Yüklenen dosyalar listesi
                ForEach(viewModel.uploadedFiles) { file in
                    HStack(spacing: 10) {
                        Image(systemName: fileIcon(for: file.format))
                            .foregroundColor(fileIconColor(for: file.format))
                            .font(AppFonts.aestetico(size: 20))
                        Text(file.name)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Button(action: { viewModel.removeFile(file) }) {
                            Image(systemName: "xmark")
                                .font(AppFonts.aestetico(size: 12, weight: .semibold))
                                .foregroundColor(AppColors.textHint)
                                .frame(width: 28, height: 28)
                                .background(AppColors.surfaceAlt)
                                .cornerRadius(6)
                        }
                    }
                    .padding(12)
                    .background(AppColors.surface)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.divider, lineWidth: 1))
                }

                // Belge ve fotoğraf yükleme yan yana; kullanıcı uygun varlık türünü seçer.
                HStack(spacing: 10) {
                    Button(action: { viewModel.showFilePicker = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperclip")
                                .foregroundColor(AppColors.primary)
                            Text(L10n.string(.taskFile, language: lang))
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isUploadingFile)

                    PhotosPicker(
                        selection: $pickedPhotoItems,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(AppColors.primary)
                            Text(L10n.string(.taskPhoto, language: lang))
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                    }
                    .disabled(viewModel.isUploadingFile)
                }

                if viewModel.isUploadingFile {
                    HStack(spacing: 6) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                            .scaleEffect(0.8)
                        Text(L10n.string(.taskUploading, language: lang))
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .onChange(of: pickedPhotoItems) { _, newItems in
            // Her seçilen fotoğrafı geçici dosyaya yazıp mevcut yükleme hattına verir (belgelerle aynı yol).
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let tmpURL = persistTempImage(data: data) {
                        viewModel.uploadFile(url: tmpURL)
                    }
                }
            }
            pickedPhotoItems.removeAll()
        }
    }

    /// Seçilen fotoğrafı önbellek klasörüne yazar ve URL döner; yükleme zinciri dosya yolu beklediği için veriyi diske yazar.
    private func persistTempImage(data: Data) -> URL? {
        let filename = "photo-\(UUID().uuidString).jpg"
        let url = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Barlanmaly işler sekmesi
    private var barlanmalyContent: some View {
        VStack(spacing: 16) {
            if viewModel.task.assignees.isEmpty {
                VStack(spacing: 12) {
                    Spacer().frame(height: 40)
                    Image(systemName: "checklist")
                        .font(AppFonts.aestetico(size: 48))
                        .foregroundColor(AppColors.textHint)
                    Text(L10n.string(.taskNoReviewItems, language: lang))
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ForEach(viewModel.task.assignees) { assignee in
                    BarlanmalyCard(
                        assignee: assignee,
                        task: viewModel.task,
                        stage: viewModel.stage(for: assignee),
                        onAccept: { viewModel.acceptAssignee(assignee) },
                        onReturnRequested: { viewModel.requestReturn(assignee) }
                    )
                }
            }
        }
    }

    // MARK: - Yardımcılar
    private func dateCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textPrimary)
            Text(value)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16)
        .stroke(AppColors.divider, lineWidth: 1))
    }

    private func formatDate(_ date: Date) -> String {
        AppDateFormatters.dayMonthYearDot.string(from: date)
    }

    private func formatTime(_ date: Date) -> String {
        AppDateFormatters.hourMinute.string(from: date)
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

// MARK: - Barlanmaly kartı
//
// Aşama (`pending` / `accepted` / `returned`) üst görünüm modelinden gelir.
// "Yzyna gaýtarmak" doğrudan reddetmez — üstte yorum sayfası açılır, sonuç `stage` ile güncellenir.
struct BarlanmalyCard: View {
    let assignee: TaskAssignee
    let task: TaskItem
    let stage: BarlanmalyStage
    var onAccept: () -> Void
    var onReturnRequested: () -> Void
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    /// Görevi oluşturanın görebildiği dosyalar (atananın yükledikleri). Şimdilik mock modelde düz `task.files` listesi kullanılır.
    private var visibleFiles: [TaskFile] { task.files }

    private var imageFiles: [TaskFile] {
        visibleFiles.filter {
            ["jpg", "jpeg", "png", "heic", "webp"].contains($0.format.lowercased())
        }
    }

    private var documentFiles: [TaskFile] {
        visibleFiles.filter {
            !["jpg", "jpeg", "png", "heic", "webp"].contains($0.format.lowercased())
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Üst bilgi: atanan + göreli zaman
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(assignee.user.name)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(task.department) / \(task.title.lowercased())")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Text(relativeTimeText)
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
            }

            // Atananın yorumu
            commentSection

            // Belgeler
            if !documentFiles.isEmpty {
                filesSection
            }

            // Görseller — satır içi önizleme
            if !imageFiles.isEmpty {
                imagesSection
            }

            // Duruma göre alt alan (onay / geri çevir vb.)
            footer
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
        .animation(.easeInOut(duration: 0.2), value: stage)
    }

    // MARK: - Bölümler

    private var commentSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(L10n.string(.taskComment, language: lang)):")
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)

            let comment = task.comments.last(where: { $0.user.id == assignee.user.id })
            Text(comment?.text ?? L10n.string(.taskNoComment, language: lang))
                .font(AppFonts.taskDescription)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppColors.surfaceAlt)
                .cornerRadius(16)
        }
    }

    private var filesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(L10n.string(.taskFiles, language: lang)):")
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textPrimary)

            ForEach(documentFiles) { file in
                HStack(spacing: 10) {
                    Image(systemName: fileIcon(for: file.format))
                        .foregroundColor(fileIconColor(for: file.format))
                        .font(AppFonts.aestetico(size: 20))
                    Text(file.name)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text(file.format.uppercased())
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textHint)
                    if let url = URL(string: file.url) {
                        Link(destination: url) {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                .padding(12)
                .background(AppColors.surfaceAlt)
                .cornerRadius(16)
            }
        }
    }

    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(L10n.string(.taskPhotos, language: lang)):")
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(imageFiles) { file in
                        if let url = URL(string: file.url) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    placeholderTile.overlay(ProgressView())
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 110)
                                        .clipped()
                                        .cornerRadius(12)
                                case .failure:
                                    placeholderTile.overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(AppColors.textHint)
                                    )
                                @unknown default:
                                    placeholderTile
                                }
                            }
                        } else {
                            placeholderTile.overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(AppColors.textHint)
                            )
                        }
                    }
                }
            }
        }
    }

    private var placeholderTile: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(AppColors.surfaceAlt)
            .frame(width: 110, height: 110)
    }

    @ViewBuilder
    private var footer: some View {
        switch stage {
        case .accepted:
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.success)
                Text(L10n.string(.taskAccepted, language: lang))
                    .font(AppFonts.subheadline)
                    .foregroundColor(AppColors.success)
            }
            .padding(.top, 4)

        case .returned(let comment):
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.error)
                    Text(L10n.string(.taskReturned, language: lang))
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.error)
                    Spacer()
                }
                Text(comment)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.error.opacity(0.08))
                    .cornerRadius(10)
            }
            .padding(.top, 4)

        case .pending:
            HStack(spacing: 12) {
                Button(action: onReturnRequested) {
                    Text(L10n.string(.taskReturnButton, language: lang))
                        .font(AppFonts.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.error)
                        )
                }
                Button(action: onAccept) {
                    Text(L10n.string(.taskAcceptButton, language: lang))
                        .font(AppFonts.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.success)
                        )
                }
            }
        }
    }

    // MARK: - Yardımcılar

    private var relativeTimeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let localeId: String
        switch lang {
        case .turkmen: localeId = "tk"
        case .turkish: localeId = "tr"
        case .english: localeId = "en"
        case .russian: localeId = "ru"
        }
        formatter.locale = Locale(identifier: localeId)
        return formatter.localizedString(for: task.createdAt, relativeTo: Date())
    }

    private func fileIcon(for format: String) -> String {
        switch format.lowercased() {
        case "pdf":                return "doc.fill"
        case "doc", "docx":        return "doc.text.fill"
        case "xls", "xlsx":        return "tablecells.fill"
        case "zip", "rar":         return "archivebox.fill"
        default:                   return "doc.fill"
        }
    }

    private func fileIconColor(for format: String) -> Color {
        switch format.lowercased() {
        case "pdf":                return .red
        case "doc", "docx":        return .cyan
        case "xls", "xlsx":        return .green
        default:                   return AppColors.textHint
        }
    }
}


