// UI/Features/CreateTasks/CreateTasksView.swift
import SwiftUI

enum ActivePicker: String, Identifiable, CaseIterable {
    case date, time
    var id: String { rawValue }

    func title(language: Language) -> String {
        switch self {
        case .date: return L10n.string(.createTaskDate, language: language)
        case .time: return L10n.string(.createTaskTime, language: language)
        }
    }
}

struct CreateTasksView: View {
    var onTaskTap: ((TaskItem) -> Void)?
    var onRefresh: (() -> Void)?
    var onTaskCreated: (() -> Void)?

    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel = CreateTasksViewModel()
    @State private var activePicker: ActivePicker? = nil
    @State private var pickerDate: Date = Date()

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text(L10n.string(.myTasksTitle, language: lang))
                        .font(AppFonts.largeTitle)
                        .foregroundColor(AppColors.textPrimary)

                    Spacer()

                    FilterChipButton(
                        title: viewModel.selectedDepartment?.name ?? L10n.string(.deptPickerAll, language: lang),
                        size: .regular,
                        leading: {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppColors.primary)
                        },
                        action: { viewModel.showDepartmentPicker = true }
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if viewModel.filteredTasks.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(AppFonts.aestetico(size: 48))
                            .foregroundColor(AppColors.textHint)
                        Text(L10n.string(.myTasksEmpty, language: lang))
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        Text(L10n.string(.myTasksEmptyHint, language: lang))
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

            FloatingActionButton(systemImage: "plus") {
                viewModel.showCreateTask = true
            }
        }
        .sheet(item: $viewModel.selectedTask) { task in
            TaskDetailView(task: task)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.showCreateTask) {
            CreateTaskView(onTaskCreated: { newTask in
                viewModel.addTask(newTask)
                viewModel.showCreateTask = false
                onRefresh?()
                onTaskCreated?()
            })
            .presentationDetents([.large])
        }
        .sheet(isPresented: $viewModel.showDepartmentPicker) {
            DepartmentPickerMini(
                departments: viewModel.departments,
                selectedDepartment: $viewModel.selectedDepartment,
                isPresented: $viewModel.showDepartmentPicker
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
    }
}

struct DepartmentPickerMini: View {
    let departments: [Department]
    @Binding var selectedDepartment: Department?
    @Binding var isPresented: Bool
    @EnvironmentObject private var container: DIContainer

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        VStack(spacing: 0) {
            SheetGrabber()

            HStack {
                Text(L10n.string(.deptPickerTitle, language: lang))
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)

            Divider().background(AppColors.divider)

            ScrollView {
                VStack(spacing: 0) {
                    SheetCheckmarkOptionRow(
                        leading: .none,
                        title: L10n.string(.deptPickerAll, language: lang),
                        horizontalInset: 20,
                        isSelected: selectedDepartment == nil
                    ) {
                        selectedDepartment = nil
                        isPresented = false
                    }

                    ForEach(departments) { dept in
                        SheetInsetDivider(horizontalInset: 20)

                        SheetCheckmarkOptionRow(
                            leading: .none,
                            title: dept.name,
                            titleFont: AppFonts.headline,
                            horizontalInset: 20,
                            isSelected: selectedDepartment?.id == dept.id
                        ) {
                            selectedDepartment = dept
                            isPresented = false
                        }
                    }
                }
            }
        }
        .background(AppColors.surface.ignoresSafeArea())
    }
}

#Preview {
    CreateTasksView()
        .background(AppColors.background)
}
