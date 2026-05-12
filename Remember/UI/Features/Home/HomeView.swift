// UI/Features/Home/HomeView.swift
import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject private var container: DIContainer
    @Environment(\.layout) private var layout

    private var lang: Language { container.appSettings.selectedLanguage }

    @StateObject private var viewModel = HomeViewModel()
    
    @State private var selectedTab: TabItem = .home
    
    @State private var selectedTask: TaskItem? = nil
    
    @State private var showTaskDetail: Bool = false
    
    @State private var isChatDetailActive: Bool = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

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
                        onRefresh: {
                            // TODO: Arka uç entegrasyonu: mevcut olduğunda veri yeniden yüklemesini tetikle
                        },
                        onTaskCreated: {
                            // TODO: Arka uç entegrasyonu: oluşturma sonrası yenileme ve yönlendirmeyi yönet
                            selectedTab = .home
                        }
                    )
                    case .users:
                    UsersView()
                    case .chats:
                        ChatsView(isChatDetailActive: $isChatDetailActive)
                    case .settings:
                    // Hakyky settings view ulanylyar
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Sekme çubuğunu VStack içinde yığmak yerine `safeAreaInset` ile
        // bağlamak iki önemli şey yapar:
        //   1. Sekme çubuğu hâlâ yerleşim alanı ayırır; böylece listeler
        //      ve mesaj balonları gibi içerikler arkasında kaybolmaz.
        //   2. Bir sohbet detayı açıldığında iç boşluk tamamen kaldırılır;
        //      bu sayede `ChatDetailView` ana göstergeye kadar uzanabilir
        //      (önceki sabit yükseklikli sekme çubuğu alanı giriş çubuğunun
        //      altında siyah bir şerit bırakıyordu).
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !isChatDetailActive {
                MainTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.85), value: isChatDetailActive)
        .onAppear {
            // Ana sekme görünür olduğunda yenilenir; böylece yeni kabul edilen
            // teklifler (`TaskRepository.addTask` ile eklenen) görünür.
            viewModel.loadData()
        }
        .sheet(isPresented: $showTaskDetail) {
            if let task = selectedTask {
                TaskDetailView(task: task)
                    .presentationDetents([.large])
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
                        .font(AppFonts.aestetico(size: 48))
                        .foregroundColor(AppColors.textHint)
                    Text(L10n.string(.noTasksFound, language: lang))
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
            } else {
                ScrollView {
                    if layout.isCompact {
                        LazyVStack(spacing: layout.spacing) {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskCard(task: task) {
                                    selectedTask = task
                                    showTaskDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, layout.gutter)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    } else {
                        LazyVGrid(
                            columns: Array(
                                repeating: GridItem(.flexible(), spacing: layout.spacing),
                                count: layout.gridColumns
                            ),
                            spacing: layout.spacing
                        ) {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskCard(task: task) {
                                    selectedTask = task
                                    showTaskDetail = true
                                }
                            }
                        }
                        .frame(maxWidth: layout.contentMaxWidth)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, layout.gutter)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }

    // MARK: - Üst çubuk (departman + durum süzgeçleri)
    //
    // Her iki çip de `compact` boyutunu kullanır; böylece ana sekmenin
    // uygulama çubuğuna düzgünce oturur. Sayfalar gizli sürükleme
    // göstergeleri ve içerik boyutuna göre ayarlanmış durak noktalarıyla sunulur.
    private var homeAppBar: some View {
        HStack(spacing: 12) {
            FilterChipButton(
                title: viewModel.selectedDepartment?.name ?? L10n.string(.deptPickerAll, language: lang),
                size: .compact,
                action: { viewModel.showDepartmentSheet = true }
            )

            Spacer()

            FilterChipButton(
                title: viewModel.selectedStatus?.displayName(language: lang) ?? L10n.string(.status, language: lang),
                size: .compact,
                leading: {
                    if let status = viewModel.selectedStatus {
                        Circle().fill(status.color).frame(width: 8, height: 8)
                    } else {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                },
                action: { viewModel.showStatusSheet = true }
            )
        }
        .padding(.horizontal, layout.gutter)
        .padding(.vertical, 10)
        .sheet(isPresented: $viewModel.showDepartmentSheet) {
            DepartmentSheet(
                selectedDepartment: $viewModel.selectedDepartment,
                isPresented: $viewModel.showDepartmentSheet,
                departments: $viewModel.departments,
                onCreateDepartment: { name in
                    // TODO: Arka uç entegrasyonu: API üzerinden departman oluştur
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showStatusSheet) {
            StatusSheet(
                selectedStatus: $viewModel.selectedStatus,
                isPresented: $viewModel.showStatusSheet
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
    }
    
}

// MARK: - Yer tutucu
struct PlaceholderTabView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(AppFonts.aestetico(size: 56))
                .foregroundColor(AppColors.textHint)
            Text(title)
                .font(AppFonts.title2)
                .foregroundColor(AppColors.textPrimary)
            Text(L10n.string(.comingSoon, language: DIContainer.shared.appSettings.selectedLanguage))
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
        .environmentObject(DIContainer.shared)
}

