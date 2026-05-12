// UI/Features/CreateTask/CreateTaskView.swift
import SwiftUI
import UniformTypeIdentifiers

struct CreateTaskView: View {
    var onTaskCreated: ((TaskItem) -> Void)?
    @StateObject private var viewModel = CreateTaskViewModel()
    @EnvironmentObject private var container: DIContainer
    @Environment(\.dismiss) private var dismiss
    @State private var showDatePickerSheet = false
    @State private var showTimePickerSheet = false

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.string(.createTaskDept, language: lang))
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            Button(action: { viewModel.showDepartmentPicker = true }) {
                                HStack {
                                    Text(viewModel.createTask.department?.name ?? L10n.string(.createTaskDeptSelect, language: lang))
                                        .font(AppFonts.body)
                                        .foregroundColor(
                                            viewModel.createTask.department != nil
                                            ? AppColors.textPrimary : AppColors.textHint
                                        )
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                .padding(14)
                                .background(AppColors.surface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.string(.createTaskName, language: lang))
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            TextField(L10n.string(.createTaskNamePlaceholder, language: lang), text: $viewModel.createTask.name)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(14)
                                .background(AppColors.surface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(L10n.string(.createTaskDescription, language: lang))
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            TextEditor(text: $viewModel.createTask.mazmuny)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 80, maxHeight: 200)
                                .padding(14)
                                .background(AppColors.surface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                        }

                        if !viewModel.isSahsy {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(L10n.string(.createTaskAssignees, language: lang))
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)

                                ForEach(viewModel.selectedUsers) { user in
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                        Text(user.name)
                                            .font(AppFonts.body)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Button(action: { viewModel.removeUser(user) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(AppColors.error)
                                        }
                                    }
                                    .padding(10)
                                    .background(AppColors.surfaceAlt)
                                    .cornerRadius(16)
                                }

                                Button(action: { viewModel.showUserPicker = true }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                            .foregroundColor(AppColors.primary)
                                        Text(L10n.string(.createTaskAddUser, language: lang))
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(AppColors.primary)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.primaryLight)
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }

                        HStack(alignment: .top, spacing: 12) {
                            dateTimePickerColumn(
                                title: L10n.string(.createTaskDueDate, language: lang),
                                valueText: formatPickerDate(viewModel.createTask.endDate),
                                systemImage: "calendar"
                            ) {
                                showDatePickerSheet = true
                            }

                            dateTimePickerColumn(
                                title: L10n.string(.createTaskDueTime, language: lang),
                                valueText: formatPickerTime(viewModel.createTask.endTime),
                                systemImage: "clock"
                            ) {
                                showTimePickerSheet = true
                            }
                        }
                        .padding(14)
                        .background(AppColors.primaryLight)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.string(.taskFile, language: lang))
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            ForEach(viewModel.selectedFiles, id: \.self) { url in
                                HStack(spacing: 10) {
                                    Image(systemName: fileIcon(for: url))
                                        .foregroundColor(AppColors.primary)
                                        .font(AppFonts.aestetico(size: 16))
                                    Text(url.lastPathComponent)
                                        .font(AppFonts.caption1)
                                        .foregroundColor(AppColors.textPrimary)
                                        .lineLimit(2)
                                    Spacer()
                                    Button(action: { viewModel.removeFile(url) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(AppColors.error)
                                            .font(AppFonts.aestetico(size: 20))
                                    }
                                }
                                .padding(10)
                                .background(AppColors.surfaceAlt)
                                .cornerRadius(16)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            Button(action: { viewModel.showFilePicker = true }) {
                                HStack {
                                    Image(systemName: "paperclip")
                                        .foregroundColor(AppColors.primary)
                                    Text(viewModel.selectedFiles.isEmpty ? L10n.string(.createTaskUploadFile, language: lang) : L10n.string(.createTaskAddFile, language: lang))
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(AppColors.primary)
                                }
                                .padding(14)
                                .background(AppColors.surface)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedFiles.count)

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.error)
                        }

                        Button(action: {
                            viewModel.createNewTask { newTask in
                                dismiss()
                                onTaskCreated?(newTask)
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView().tint(AppColors.textInverse)
                                }
                                Text(L10n.string(.createTaskSubmit, language: lang))
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textInverse)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(viewModel.createTask.isValid
                                          ? AppColors.buttonActive
                                          : AppColors.buttonDisabled)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        viewModel.createTask.isValid
                                            ? Color.clear
                                            : AppColors.divider,
                                        lineWidth: 1
                                    )
                            )
                        }
                        .disabled(!viewModel.createTask.isValid || viewModel.isLoading)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.createTask.isValid)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(L10n.string(.createTaskTitle, language: lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.string(.createTaskClose, language: lang)) { dismiss() }
                        .foregroundColor(AppColors.primary)
                }
            }
            .toolbarBackground(AppColors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $viewModel.showDepartmentPicker) {
            CreateTaskDepartmentPicker(viewModel: viewModel)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showUserPicker) {
            UserPickerSheet(viewModel: viewModel)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showDatePickerSheet) {
            NavigationStack {
                DatePicker(
                    "",
                    selection: $viewModel.createTask.endDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(AppColors.primary)
                .padding()
                .background(AppColors.background)
                .navigationTitle(L10n.string(.createTaskDate, language: lang))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(L10n.string(.createTaskAccept, language: lang)) { showDatePickerSheet = false }
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showTimePickerSheet) {
            NavigationStack {
                DatePicker(
                    "",
                    selection: $viewModel.createTask.endTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(AppColors.primary)
                .padding()
                .background(AppColors.background)
                .navigationTitle(L10n.string(.createTaskTime, language: lang))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(L10n.string(.createTaskAccept, language: lang)) { showTimePickerSheet = false }
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .fileImporter(
            isPresented: $viewModel.showFilePicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    let accessing = url.startAccessingSecurityScopedResource()
                    viewModel.addFile(url)
                    if accessing {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }

    private func dateTimePickerColumn(
        title: String,
        valueText: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: 10) {
                    Image(systemName: systemImage)
                        .font(AppFonts.aestetico(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                    Text(valueText)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(AppFonts.aestetico(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textHint)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.surfaceAlt)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private func formatPickerDate(_ date: Date) -> String {
        AppDateFormatters.dayMonthYearShort.string(from: date)
    }

    private func formatPickerTime(_ date: Date) -> String {
        AppDateFormatters.hourMinute.string(from: date)
    }

    private func fileIcon(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf":                          return "doc.richtext.fill"
        case "png", "jpg", "jpeg", "heic":  return "photo.fill"
        case "mp4", "mov":                   return "video.fill"
        case "mp3", "m4a", "wav":           return "waveform"
        case "zip", "rar":                   return "archivebox.fill"
        case "doc", "docx":                  return "doc.text.fill"
        case "xls", "xlsx":                  return "tablecells.fill"
        default:                             return "paperclip"
        }
    }
}

struct CreateTaskDepartmentPicker: View {
    @ObservedObject var viewModel: CreateTaskViewModel
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(L10n.string(.createTaskDeptSelect, language: lang))
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(20)

            Divider().background(AppColors.divider)

            ScrollView {
                VStack(spacing: 0) {
                    SheetCheckmarkOptionRow(
                        leading: .symbol(name: "person.fill", foreground: AppColors.primary, width: 20),
                        title: L10n.string(.createTaskPersonal, language: lang),
                        horizontalInset: 20,
                        isSelected: viewModel.createTask.department?.id == "sahsy"
                    ) {
                        viewModel.createTask.department = Department.sahsy
                        viewModel.selectedUsers = []
                        viewModel.createTask.assigneeIDs = []
                        viewModel.showDepartmentPicker = false
                    }

                    SheetInsetDivider(horizontalInset: 20)

                    ForEach(viewModel.departments) { dept in
                        SheetCheckmarkOptionRow(
                            leading: .none,
                            title: dept.name,
                            horizontalInset: 20,
                            isSelected: viewModel.createTask.department?.id == dept.id
                        ) {
                            viewModel.createTask.department = dept
                            viewModel.showDepartmentPicker = false
                        }

                        SheetInsetDivider(horizontalInset: 20)
                    }
                }
            }

            HStack(spacing: 12) {
                    TextField(L10n.string(.createTaskNewDept, language: lang), text: $viewModel.newDepartmentName)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppColors.surfaceAlt)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )

                Button(action: { viewModel.addNewDepartment() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(AppFonts.aestetico(size: 28))
                        .foregroundColor(AppColors.primary)
                }
                .disabled(viewModel.newDepartmentName.isEmpty)
            }
            .padding(20)
        }
        .background(AppColors.surface)
    }
}

struct UserPickerSheet: View {
    @ObservedObject var viewModel: CreateTaskViewModel
    @EnvironmentObject private var container: DIContainer
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var showMyUsers: Bool = true

    private var lang: Language { container.appSettings.selectedLanguage }

    var filteredUsers: [User] {
        if searchText.isEmpty { return viewModel.allUsers }
        return viewModel.allUsers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.phone.contains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    TextField(L10n.string(.userPickerSearch, language: lang), text: $searchText)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Button(action: { withAnimation { showMyUsers.toggle() } }) {
                        HStack {
                            Text(L10n.string(.userPickerMyUsers, language: lang))
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Image(systemName: showMyUsers ? "chevron.down" : "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                    }

                    Divider().background(AppColors.divider)

                    if showMyUsers {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(filteredUsers) { user in
                                    let isSelected = viewModel.selectedUsers.contains(where: { $0.id == user.id })

                                    Button(action: {
                                        if isSelected {
                                            viewModel.removeUser(user)
                                        } else {
                                            viewModel.addUser(user)
                                        }
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "person.circle.fill")
                                                .font(AppFonts.aestetico(size: 32))
                                                .foregroundColor(isSelected ? AppColors.primary : AppColors.textHint)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(user.name)
                                                    .font(AppFonts.body)
                                                    .foregroundColor(AppColors.textPrimary)
                                                Text(user.phone)
                                                    .font(AppFonts.caption1)
                                                    .foregroundColor(AppColors.textSecondary)
                                            }

                                            Spacer()

                                            if isSelected {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(AppColors.primary)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                    }

                                    Divider().background(AppColors.divider).padding(.horizontal, 20)
                                }
                            }
                        }
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        Button(action: { dismiss() }) {
                            Text(L10n.string(.userPickerClose, language: lang))
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.surfaceLight)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                        }

                        Button(action: { dismiss() }) {
                            Text(L10n.string(.userPickerAdd, language: lang))
                                .font(AppFonts.headline)
                                .foregroundColor(AppColors.textInverse)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(AppColors.buttonActive)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle(L10n.string(.userPickerTitle, language: lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

#Preview {
    CreateTaskView()
        .environmentObject(AppRouter())
}
