// UI/Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: TabItem = .home
    @State private var selectedTask: TaskItem? = nil
    @State private var showTaskDetail: Bool = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .home:
                        homeContent
                    case .createTask:
                        CreateTasksView(
                            onTaskTap: { task in
                                selectedTask = task
                                showTaskDetail = true
                            },
                            onRefresh: { viewModel.loadData() }
                        )
                    case .users:
                        UsersView()
                    case .chats:
                        ChatsView()
                    case .settings:
                        // Hakyky settings view ulanylyar
                        SettingsView()
                    }
                }
                .frame(maxHeight: .infinity)

                // TabBar
                MainTabBar(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .sheet(isPresented: $showTaskDetail) {
            if let task = selectedTask {
                TaskDetailView(task: task)
                    .presentationDetents([.large])
                    .preferredColorScheme(.dark)
            }
        }
    }

    // MARK: Home Tab
    private var homeContent: some View {
        VStack(spacing: 0) {
            homeAppBar

            if viewModel.isLoading {
                Spacer()
                ProgressView().tint(AppColors.primary).scaleEffect(1.2)
                Spacer()
            } else if viewModel.filteredTasks.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.textHint)
                    Text("Iş tapylmady")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredTasks) { task in
                            TaskCard(task: task) {
                                selectedTask = task
                                showTaskDetail = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK:  AppBar 
    private var homeAppBar: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.showDepartmentSheet = true }) {
                HStack(spacing: 6) {
                    Text(viewModel.selectedDepartment?.name ?? "Hemmesi")
                        .font(AppFonts.headline)
                        .foregroundColor(.white)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppColors.surface)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
            }

            Spacer()

            Button(action: { viewModel.showStatusSheet = true }) {
                HStack(spacing: 6) {
                    if let status = viewModel.selectedStatus {
                        Circle().fill(status.color).frame(width: 8, height: 8)
                        Text(status.displayName)
                            .font(AppFonts.subheadline)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.textSecondary)
                        Text("Yagday")
                            .font(AppFonts.subheadline)
                            .foregroundColor(.white)
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppColors.surface)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .sheet(isPresented: $viewModel.showDepartmentSheet) {
            DepartmentSheet(
                selectedDepartment: $viewModel.selectedDepartment,
                isPresented: $viewModel.showDepartmentSheet,
                departments: $viewModel.departments,
                onCreateDepartment: { name in
                    await viewModel.createDepartment(name: name)
                }
            )
            .presentationDetents([.medium])
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $viewModel.showStatusSheet) {
            StatusSheet(
                selectedStatus: $viewModel.selectedStatus,
                isPresented: $viewModel.showStatusSheet
            )
            .presentationDetents([.medium])
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Placeholder
struct PlaceholderTabView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(AppColors.textHint)
            Text(title)
                .font(AppFonts.title2)
                .foregroundColor(.white)
            Text("Ýakyn wagtda gelýär...")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
}

#Preview {
    HomeView().environmentObject(AppRouter())
}
