// UI/Features/CreateTasks/CreateTasksView.swift
import SwiftUI

/// Tab 2 — "Iş döretmek" bölümü
struct CreateTasksView: View {
    var onTaskTap: ((TaskItem) -> Void)?
    var onRefresh: (() -> Void)?

    @StateObject private var viewModel = CreateTasksViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // AppBar
                HStack {
                    Text("Iş döretmek")
                        .font(AppFonts.title2)
                        .foregroundColor(.white)

                    Spacer()

                    Button(action: { viewModel.showDepartmentPicker = true }) {
                        HStack(spacing: 4) {
                            Text(viewModel.selectedDepartment?.name ?? "Hemmesi")
                                .font(AppFonts.subheadline)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.surface)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Task listi
                if viewModel.filteredTasks.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textHint)
                        Text("Heniz iş ýok")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        Text("Täze iş döretmek üçin + basyň")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textHint)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredTasks) { task in
                                CreatedTaskCard(task: task) {
                                    viewModel.selectedTask = task
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 80)
                    }
                }
            }

            // '+' button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { viewModel.showCreateTask = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppColors.primary, AppColors.primaryDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: AppColors.primary.opacity(0.4), radius: 12, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 8)
                }
            }
        }
        .sheet(item: $viewModel.selectedTask) { task in
            TaskDetailView(task: task)
                .presentationDetents([.large])
                .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $viewModel.showCreateTask) {
            CreateTaskView(onTaskCreated: {
                viewModel.showCreateTask = false
                viewModel.loadData()
                onRefresh?()
            })
            .presentationDetents([.large])
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $viewModel.showDepartmentPicker) {
            DepartmentPickerMini(
                departments: viewModel.departments,
                selectedDepartment: $viewModel.selectedDepartment,
                isPresented: $viewModel.showDepartmentPicker
            )
            .presentationDetents([.medium])
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Mini Department Picker
struct DepartmentPickerMini: View {
    let departments: [Department]
    @Binding var selectedDepartment: Department?
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bölüm saýlaň")
                    .font(AppFonts.title3)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(20)

            Divider().background(AppColors.divider)

            ScrollView {
                VStack(spacing: 0) {
                    Button(action: {
                        selectedDepartment = nil
                        isPresented = false
                    }) {
                        HStack {
                            Text("Hemmesi")
                                .font(AppFonts.body).foregroundColor(.white)
                            Spacer()
                            if selectedDepartment == nil {
                                Image(systemName: "checkmark").foregroundColor(AppColors.primary)
                            }
                        }
                        .padding(.horizontal, 20).padding(.vertical, 14)
                    }

                    ForEach(departments) { dept in
                        Divider().background(AppColors.divider).padding(.horizontal, 20)
                        Button(action: {
                            selectedDepartment = dept
                            isPresented = false
                        }) {
                            HStack {
                                Text(dept.name)
                                    .font(AppFonts.body).foregroundColor(.white)
                                Spacer()
                                if selectedDepartment?.id == dept.id {
                                    Image(systemName: "checkmark").foregroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal, 20).padding(.vertical, 14)
                        }
                    }
                }
            }
        }
        .background(AppColors.surface)
    }
}

// MARK: - Preview
#Preview {
    CreateTasksView()
        .background(AppColors.background)
        .preferredColorScheme(.dark)
}
