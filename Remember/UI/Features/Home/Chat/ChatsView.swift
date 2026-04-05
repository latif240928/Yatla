// UI/Features/Chats/ChatsView.swift
import SwiftUI

struct ChatsView: View {
    @StateObject private var viewModel = ChatsViewModel()
    @State private var selectedTab: ChatsTab = .chatlar
    @State private var isSearching: Bool = false
    @State private var searchText: String = ""
    @State private var showDepartmentSheet: Bool = false
    @State private var showAddUserSheet: Bool = false

    enum ChatsTab { case chatlar, grupbalar }

    var filteredChats: [Chat] {
        guard !searchText.isEmpty else { return viewModel.chats }
        return viewModel.chats.filter {
            $0.participant.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var filteredGroups: [GroupChat] {
        guard !searchText.isEmpty else { return viewModel.groupChats }
        return viewModel.groupChats.filter {
            $0.department.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {

                    // AppBar
                    HStack(spacing: 12) {
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                showDepartmentSheet = true
                            }
                        }) {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.primary)
                                        .frame(width: 36, height: 36)
                                    Text("A")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                Text(viewModel.selectedDepartment?.name ?? "Ähli bölümler")
                                    .font(AppFonts.headline)
                                    .foregroundColor(.white)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
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
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(AppColors.surface)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    // Search TextField
                    if isSearching {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary)
                            TextField("Gözleg...", text: $searchText)
                                .font(AppFonts.body)
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppColors.surface)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal:   .move(edge: .top).combined(with: .opacity)
                        ))
                    }

                    //  Tab saylayjy
                    HStack(spacing: 0) {
                        tabButton(title: "Çatlar",   tab: .chatlar)
                        tabButton(title: "Grupbalar", tab: .grupbalar)
                    }
                    .padding(4)
                    .background(AppColors.surface)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    //
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            switch selectedTab {
                            case .chatlar:   chatsContent
                            case .grupbalar: groupsContent
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                    }
                }

                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddUserSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle().fill(
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
            // ── Bölüm sheet ────────────────────────────────────────────────
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
                .preferredColorScheme(.dark)
            }
            // ── AddUser sheet ──────────────────────────────────────────────
            .sheet(isPresented: $showAddUserSheet) {
                AddUserSheet(
                    isPresented: $showAddUserSheet,
                    departments: viewModel.departments,
                    onInvite: { name, phone, dept in
                        Task { await viewModel.inviteUser(name: name, phone: phone, department: dept) }
                    }
                )
                .presentationDetents([.medium])
                .preferredColorScheme(.dark)
            }
        }
    }

    // MARK: - Çatlar (swipe: poz + sessiz) ─────────────────────────────────
    @ViewBuilder
    private var chatsContent: some View {
        ForEach(filteredChats) { chat in
            NavigationLink(destination: ChatDetailView(chat: chat, viewModel: viewModel)) {
                ChatRowView(chat: chat)
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                // poz
                Button(role: .destructive) {
                    Task { await viewModel.deleteChat(id: chat.id) }
                } label: {
                    Label("Poz", systemImage: "trash.fill")
                }
                // Sessiz / Ses aç
                Button {
                    Task { await viewModel.toggleMute(chat: chat) }
                } label: {
                    Label(
                        chat.isMuted ? "Sesi aç" : "Sessiz",
                        systemImage: chat.isMuted ? "bell.fill" : "bell.slash.fill"
                    )
                }
                .tint(AppColors.surfaceLight)
            }
        }
    }

    // MARK: - Grupbalar ──────────────────────────────────────────────────────
    @ViewBuilder
    private var groupsContent: some View {
        ForEach(filteredGroups) { group in
            GroupChatRowView(group: group)
        }
    }

    // MARK: - Tab butonu ─────────────────────────────────────────────────────
    private func tabButton(title: String, tab: ChatsTab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
        }) {
            Text(title)
                .font(AppFonts.subheadline)
                .foregroundColor(selectedTab == tab ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedTab == tab ? AppColors.surfaceLight : Color.clear)
                .cornerRadius(8)
        }
    }
}

#Preview {
    ChatsView().preferredColorScheme(.dark)
}
