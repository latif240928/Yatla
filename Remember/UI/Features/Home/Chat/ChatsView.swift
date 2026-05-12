// UI/Features/Chats/ChatsView.swift
import SwiftUI

struct ChatsView: View {
    @EnvironmentObject private var container: DIContainer
    @Binding var isChatDetailActive: Bool
    @StateObject private var viewModel = ChatsViewModel()
    @State private var selectedTab: ChatsTab = .chatlar
    @State private var isSearching: Bool = false
    @State private var searchText: String = ""
    @State private var showDepartmentSheet: Bool = false
    @State private var showAddUserSheet: Bool = false
    @State private var chatPath = NavigationPath()

    enum ChatsTab { case chatlar, grupbalar }

    /// Aynı `NavigationStack` yolundan hem bire bir sohbete hem de
    /// departman genelinde grup sohbetine yönlendirme yapabilmek için ayrımlı birleşim.
    enum ChatRoute: Hashable {
        case direct(chatId: String)
        case group(groupId: String)
    }

    private var lang: Language { container.appSettings.selectedLanguage }

    var filteredChats: [Chat] {
        guard !searchText.isEmpty else { return viewModel.chats }
        return viewModel.chats.filter {
            $0.participant.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack(path: $chatPath) {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    if chatPath.isEmpty {
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    showDepartmentSheet = true
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Text(viewModel.selectedDepartment?.name ?? L10n.string(.chatsAllDepartments, language: lang))
                                        .font(AppFonts.deptitle)
                                        .foregroundColor(AppColors.textPrimary)
                                    Image(systemName: "chevron.down")
                                        .font(AppFonts.aestetico(size: 15, weight: .semibold))
                                        .foregroundColor(AppColors.textSecondary)
                                        .rotationEffect(.degrees(showDepartmentSheet ? 180 : 0))
                                        .animation(.easeInOut(duration: 0.2), value: showDepartmentSheet)
                                }
                            }

                            Spacer()

                            Button(action: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    isSearching.toggle()
                                    if !isSearching { searchText = "" }
                                }
                            }) {
                                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                                    .font(AppFonts.aestetico(size: 18))
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(width: 36, height: 36)
                                    .background(AppColors.surface)
                                    .cornerRadius(16)
                                    .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 4, y: 2)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.divider, lineWidth: 1)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 12)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                    }

                    if isSearching {
                        TextField(L10n.string(.search, language: lang), text: $searchText)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(12)
                            .background(AppColors.surface)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.borderFocused, lineWidth: 2)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                            .autocorrectionDisabled()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    if chatPath.isEmpty {
                        HStack(spacing: 0) {
                            tabButton(title: L10n.string(.chatsPrivateChats, language: lang), tab: .chatlar)
                            tabButton(title: L10n.string(.chatsGroups, language: lang), tab: .grupbalar)
                        }
                        .padding(4)
                        .background(AppColors.surface)
                        .cornerRadius(26)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        ))
                    }

                    ScrollView {
                        LazyVStack(spacing: 10) {
                            switch selectedTab {
                            case .chatlar: chatsContent
                            case .grupbalar: groupsContent
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                    }
                }

                if chatPath.isEmpty {
                    FloatingActionButton(systemImage: "plus") {
                        showAddUserSheet = true
                    }
                    .transition(.opacity)
                }
            }
            .onAppear {
                if chatPath.isEmpty {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        isChatDetailActive = false
                    }
                }
            }
            .animation(.easeInOut(duration: 0.22), value: chatPath.isEmpty)
            .navigationDestination(for: ChatRoute.self) { route in
                switch route {
                case .direct(let chatId):
                    if let chat = viewModel.chats.first(where: { $0.id == chatId }) {
                        ChatDetailView(
                            chat: chat,
                            viewModel: viewModel,
                            isChatDetailActive: $isChatDetailActive
                        )
                    } else {
                        Text("Çat tapylmady")
                            .foregroundColor(AppColors.textSecondary)
                    }
                case .group(let groupId):
                    GroupChatDetailView(
                        groupId: groupId,
                        viewModel: viewModel,
                        isChatDetailActive: $isChatDetailActive
                    )
                }
            }
            .sheet(isPresented: $showDepartmentSheet) {
                DepartmentSheet(
                    selectedDepartment: $viewModel.selectedDepartment,
                    isPresented: $showDepartmentSheet,
                    departments: $viewModel.departments,
                    onCreateDepartment: { name in
                        await viewModel.createDepartment(name: name)
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showAddUserSheet) {
                AddUserSheet(
                    isPresented: $showAddUserSheet,
                    departments: viewModel.departments,
                    onInvite: { name, phone, dept in
                        Task { await viewModel.inviteUser(name: name, phone: phone, department: dept) }
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
            }
            .onChange(of: chatPath.count) { _, newCount in
                withAnimation(.easeInOut(duration: 0.22)) {
                    isChatDetailActive = newCount > 0
                }
            }
        }
    }

    @ViewBuilder
    private var chatsContent: some View {
        ForEach(filteredChats) { chat in
            NavigationLink(value: ChatRoute.direct(chatId: chat.id)) {
                ChatRowView(chat: chat)
            }
            // Basıldığında yay ölçekleme + hafif dokunsal geri bildirim — bkz. PressedScaleStyle.
            .buttonStyle(PressedScaleStyle())
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity
            ))
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    Task { await viewModel.deleteChat(id: chat.id) }
                } label: {
                    Label(L10n.string(.actionDelete, language: lang), systemImage: "trash.fill")
                }
                Button {
                    Task { await viewModel.toggleMute(chat: chat) }
                } label: {
                    Label(
                        chat.isMuted ? L10n.string(.chatsUnmute, language: lang) : L10n.string(.chatsMute, language: lang),
                        systemImage: chat.isMuted ? "bell.fill" : "bell.slash.fill"
                    )
                }
                .tint(AppColors.surfaceLight)
            }
        }
    }

    /// Departman genelinde grup sohbetleri. Her departman tek bir kart olur;
    /// karta dokunmak o departmandaki tüm kullanıcıları aynı
    /// sohbet dizisine yönlendirir.
    @ViewBuilder
    private var groupsContent: some View {
        ForEach(viewModel.departmentsForGroupDirectory, id: \.id) { dept in
            let users = viewModel.users(in: dept)
            // Üyesi olmayan departmanları gizle; liste boş görünmesin.
            if !users.isEmpty {
                let group = viewModel.groupChats.first(where: { $0.department.id == dept.id })
                DepartmentGroupCard(
                    department: dept,
                    memberCount: users.count,
                    lastMessage: group?.lastMessage,
                    unreadCount: group?.unreadCount ?? 0,
                    onTap: {
                        let groupId = viewModel.openOrCreateGroupChat(for: dept)
                        chatPath.append(ChatRoute.group(groupId: groupId))
                    }
                )
            }
        }
    }

    private func tabButton(title: String, tab: ChatsTab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
        }) {
            Text(title)
                .font(AppFonts.subheadline)
                .foregroundColor(selectedTab == tab ? AppColors.textPrimary : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedTab == tab ? AppColors.surfaceLight : Color.clear)
                .cornerRadius(16)
        }
    }
}
