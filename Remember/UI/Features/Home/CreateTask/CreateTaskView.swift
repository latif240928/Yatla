// UI/Features/CreateTask/CreateTaskView.swift
import SwiftUI

/// Task doretmek popup  — '+' butronundan açylyar
struct CreateTaskView: View {
    var onTaskCreated: (() -> Void)?
    @StateObject private var viewModel = CreateTaskViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Department saylamak
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Bölüm")
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            Button(action: { viewModel.showDepartmentPicker = true }) {
                                HStack {
                                    Text(viewModel.createTask.department?.name ?? "Bölüm saýlaň...")
                                        .font(AppFonts.body)
                                        .foregroundColor(
                                            viewModel.createTask.department != nil
                                            ? .white : AppColors.textHint
                                        )
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(AppColors.textSecondary)
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

                        // MARK: - Iş ady
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Işin ady")
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            TextField("Işin adyny ýazyň...", text: $viewModel.createTask.name)
                                .font(AppFonts.body)
                                .foregroundColor(.white)
                                .padding(14)
                                .background(AppColors.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                        }

                        // MARK: - Mazmuny
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Mazmuny")
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            TextEditor(text: $viewModel.createTask.mazmuny)
                                .font(AppFonts.body)
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 80, maxHeight: 200)
                                .padding(14)
                                .background(AppColors.surface)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(AppColors.divider, lineWidth: 1)
                                )
                        }

                        // MARK: - Kullanıcılar — Şahsy saylanan bolsa gizle
                        if !viewModel.isSahsy {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Degişli adamlar")
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)

                                ForEach(viewModel.selectedUsers) { user in
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                        Text(user.name)
                                            .font(AppFonts.body)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Button(action: { viewModel.removeUser(user) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(AppColors.error)
                                        }
                                    }
                                    .padding(10)
                                    .background(AppColors.surfaceAlt)
                                    .cornerRadius(8)
                                }

                                Button(action: { viewModel.showUserPicker = true }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                            .foregroundColor(AppColors.primary)
                                        Text("Ulanyjy goşmak")
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(AppColors.primary)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(AppColors.primary.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }

                        // MARK: - deadline + sagat
                        HStack(alignment: .top) {

                            // (Date)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Tamamlanmaly senesi")
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)

                                DatePicker(
                                    "",
                                    selection: $viewModel.createTask.endDate,
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(AppColors.textPrimary)
                            }

                            Spacer()

                            //  (Time)
                            VStack(alignment: .trailing, spacing: 6) {
                                Text("Wagty")
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(width: 90)

                                DatePicker(
                                    "",
                                    selection: $viewModel.createTask.endTime,
                                    displayedComponents: [.hourAndMinute]
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(AppColors.textPrimary)
                                .frame(width: 90)
                            }
                        }
                        .padding(14)
                        .background(AppColors.surface)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )

                        // MARK: - Faýl
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Faýl")
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)

                            Button(action: { /* File picker */ }) {
                                HStack {
                                    Image(systemName: "paperclip")
                                        .foregroundColor(AppColors.primary)
                                    Text("Faýl ýüklemek")
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                    Image(systemName: "plus.circle")
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

                        // MARK: - Error
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.error)
                        }

                        // MARK: - Döretmek button
                        Button(action: {
                            viewModel.createNewTask {
                                onTaskCreated?()
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                }
                                Text("Döretmek")
                                    .font(AppFonts.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(viewModel.createTask.isValid
                                          ? AppColors.buttonActive
                                          : AppColors.buttonDisabled)
                            )
                        }
                        .disabled(!viewModel.createTask.isValid || viewModel.isLoading)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Täze iş")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ýap") { dismiss() }
                        .foregroundColor(AppColors.primary)
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .sheet(isPresented: $viewModel.showDepartmentPicker) {
            CreateTaskDepartmentPicker(viewModel: viewModel)
                .presentationDetents([.medium])
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $viewModel.showUserPicker) {
            UserPickerSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Department Picker
struct CreateTaskDepartmentPicker: View {
    @ObservedObject var viewModel: CreateTaskViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bölüm saýlaň")
                    .font(AppFonts.title3).foregroundColor(.white)
                Spacer()
            }
            .padding(20)

            Divider().background(AppColors.divider)

            ScrollView {
                VStack(spacing: 0) {

                    //  Şahsy
                    Button(action: {
                        viewModel.createTask.department = Department.sahsy
                        viewModel.selectedUsers = []
                        viewModel.createTask.assigneeIDs = []
                        viewModel.showDepartmentPicker = false
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(AppColors.primary)
                                .frame(width: 20)
                            Text("Şahsy")
                                .font(AppFonts.body).foregroundColor(.white)
                            Spacer()
                            if viewModel.createTask.department?.id == "sahsy" {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)
                    }

                    Divider().background(AppColors.divider).padding(.horizontal, 20)

                    
                    ForEach(viewModel.departments) { dept in
                        Button(action: {
                            viewModel.createTask.department = dept
                            viewModel.showDepartmentPicker = false
                        }) {
                            HStack {
                                Text(dept.name)
                                    .font(AppFonts.body).foregroundColor(.white)
                                Spacer()
                                if viewModel.createTask.department?.id == dept.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal, 20).padding(.vertical, 14)
                        }
                        Divider().background(AppColors.divider).padding(.horizontal, 20)
                    }
                }
            }

            // Bölüm gosmak
            HStack(spacing: 12) {
                TextField("Täze bölüm...", text: $viewModel.newDepartmentName)
                    .font(AppFonts.body).foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 10)
                    .background(AppColors.surfaceAlt).cornerRadius(8)

                Button(action: { viewModel.addNewDepartment() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primary)
                }
                .disabled(viewModel.newDepartmentName.isEmpty)
            }
            .padding(20)
        }
        .background(AppColors.surface)
    }
}

// MARK: - User Picker Sheet
struct UserPickerSheet: View {
    @ObservedObject var viewModel: CreateTaskViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var showMyUsers: Bool = true

    var filteredUsers: [User] {
        if searchText.isEmpty {
            return viewModel.allUsers
        }
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
                    VStack(spacing: 12) {
                        TextField("Ulanyjy ady...", text: $searchText)
                            .font(AppFonts.body).foregroundColor(.white)
                            .padding(12)
                            .background(AppColors.surface).cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppColors.divider, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Button(action: { withAnimation { showMyUsers.toggle() } }) {
                        HStack {
                            Text("Meniň ulanyjylarym")
                                .font(AppFonts.headline)
                                .foregroundColor(.white)
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
                                                .font(.system(size: 32))
                                                .foregroundColor(isSelected ? AppColors.primary : AppColors.textHint)

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(user.name)
                                                    .font(AppFonts.body)
                                                    .foregroundColor(.white)
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
                            Text("Ýap")
                                .font(AppFonts.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.surfaceLight))
                        }

                        Button(action: { dismiss() }) {
                            Text("Goşmak")
                                .font(AppFonts.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.buttonActive))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Ulanyjy saýlaň")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    CreateTaskView()
        .environmentObject(AppRouter())
}
