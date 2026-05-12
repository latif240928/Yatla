// UI/Features/Users/UsersView.swift
import SwiftUI

struct UsersView: View {
    @StateObject private var viewModel = UsersViewModel()
    @EnvironmentObject private var container: DIContainer
    @State private var selectedTab: UsersTab = .users
    @State private var showSearch: Bool = false
    @State private var selectedUser: User? = nil
    @State private var searchText: String = ""

    private var lang: Language { container.appSettings.selectedLanguage }

    enum UsersTab {
        case users, invitations
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button(action: { viewModel.showDepartmentSheet = true }) {
                        HStack(spacing: 8) {
                            Text(viewModel.selectedDepartment.name)
                                .font(AppFonts.deptitle)
                                .foregroundColor(AppColors.textPrimary)
                            Image(systemName: "chevron.down")
                                .font(AppFonts.aestetico(size: 17, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    Button(action: { withAnimation { showSearch.toggle() } }) {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
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

                if showSearch {
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

                HStack(spacing: 0) {
                    tabButton(title: L10n.string(.usersTabUsers, language: lang), tab: .users)
                    tabButton(title: L10n.string(.usersTabInvitations, language: lang), tab: .invitations)
                }
                .padding(4)
                .background(AppColors.surface)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.divider, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                ScrollView {
                    LazyVStack(spacing: 12) {
                        switch selectedTab {
                        case .users:
                            usersContent
                        case .invitations:
                            invitationsContent
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80)
                }
            }

            FloatingActionButton(systemImage: "plus") {
                viewModel.showAddUserSheet = true
            }
        }
        .sheet(isPresented: $viewModel.showAddUserSheet) {
            AddUserSheet(
                isPresented: $viewModel.showAddUserSheet,
                departments: viewModel.departments,
                onInvite: { name, phone, dept in
                    viewModel.inviteUser(name: name, phone: phone, department: dept)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $viewModel.showDepartmentSheet) {
            DepartmentSheet(
                selectedDepartment: Binding(
                    get: { viewModel.selectedDepartment as Department? },
                    set: { if let d = $0 { viewModel.selectedDepartment = d } }
                ),
                isPresented: $viewModel.showDepartmentSheet,
                departments: $viewModel.departments,
                onCreateDepartment: { _ in }
            )
            .presentationDetents([.medium])
        }
        .sheet(item: $selectedUser) { user in
            UserDetailView(user: user)
                .presentationDetents([.large])
        }
        // Silme onayı – `UserCard` üzerindeki çöp kutusu simgesi yalnızca bir
        // istek hazırlar; asıl silme "Howa" sonrasında gerçekleşir.
        .alert(
            L10n.string(.usersDeleteConfirmTitle, language: lang),
            isPresented: Binding(
                get: { viewModel.pendingDeletionUser != nil },
                set: { newValue in
                    if !newValue { viewModel.cancelDeletePendingUser() }
                }
            ),
            presenting: viewModel.pendingDeletionUser
        ) { user in
            Button(L10n.string(.actionYes, language: lang), role: .destructive) {
                viewModel.confirmDeletePendingUser()
            }
            Button(L10n.string(.actionNo, language: lang), role: .cancel) {
                viewModel.cancelDeletePendingUser()
            }
        } message: { user in
            Text(L10n.string(.usersDeleteConfirmMessage, language: lang))
        }
    }

    @ViewBuilder
    private var usersContent: some View {
        if viewModel.filteredUsers.isEmpty {
            VStack(spacing: 12) {
                Spacer().frame(height: 40)
                Image(systemName: "person.2")
                    .font(AppFonts.aestetico(size: 48))
                    .foregroundColor(AppColors.textHint)
                Text(L10n.string(.usersNoUsers, language: lang))
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        } else {
            ForEach(viewModel.filteredUsers) { user in
                UserCard(
                    user: user,
                    stats: viewModel.taskStats(for: user.id),
                    departments: viewModel.departments,
                    onDelete: { viewModel.requestDeleteUser(user) },
                    onTap: { selectedUser = user }
                )
            }
        }
    }

    @ViewBuilder
    private var invitationsContent: some View {
        if viewModel.incomingOffers.isEmpty {
            VStack(spacing: 12) {
                Spacer().frame(height: 40)
                Image(systemName: "envelope")
                    .font(AppFonts.aestetico(size: 48))
                    .foregroundColor(AppColors.textHint)
                Text(L10n.string(.usersNoInvitations, language: lang))
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        } else {
            ForEach(viewModel.incomingOffers) { offer in
                InvitationCard(
                    offer: offer,
                    departments: viewModel.departments,
                    onAccept: { viewModel.acceptOffer(offer) },
                    onReject: { viewModel.rejectOffer(offer) }
                )
            }
        }
    }

    private func tabButton(title: String, tab: UsersTab) -> some View {
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

#Preview {
    UsersView()
}
