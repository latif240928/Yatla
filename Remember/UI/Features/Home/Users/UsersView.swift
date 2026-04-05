
// UI/Features/Users/UsersView.swift
import SwiftUI

struct UsersView: View {
    @StateObject private var viewModel = UsersViewModel()
    @State private var selectedTab: UsersTab = .users
    @State private var showSearch: Bool = false
    @State private var selectedUser: User? = nil

    enum UsersTab {
        case users, invitations
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - AppBar
                HStack(spacing: 12) {
                    // Avatar + Department
                    Button(action: { viewModel.showDepartmentSheet = true }) {
                        HStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primary)
                                    .frame(width: 36, height: 36)
                                Text("A")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Text(viewModel.selectedDepartment.name)
                                .font(AppFonts.headline)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    // Search butonu
                    Button(action: { withAnimation { showSearch.toggle() } }) {
                        Image(systemName: "magnifyingglass")
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

                // search field
                if showSearch {
                    TextField("Ulanyjy ady ýa-da nomeri...", text: $viewModel.searchQuery)
                        .font(AppFonts.body)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(AppColors.surface)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // MARK: - Tab saylayjy
                HStack(spacing: 0) {
                    tabButton(title: "Ulanyjylar", tab: .users)
                    tabButton(title: "Meni çagyranlar", tab: .invitations)
                }
                .padding(4)
                .background(AppColors.surface)
                .cornerRadius(10)
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

            // MARK: '+' butonu
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { viewModel.showAddUserSheet = true }) {
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
        // AddUser sheet
        .overlay(
            Group {
                if viewModel.showAddUserSheet {
                    AddUserSheet(
                        isPresented: $viewModel.showAddUserSheet,
                        departments: viewModel.departments,
                        onInvite: { name, phone, dept in
                            viewModel.inviteUser(name: name, phone: phone, department: dept)
                        }
                    )
                    .transition(.opacity)
                }
            }
        )
        // UserDetail sheet
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
            .preferredColorScheme(.dark)
        }
        
        .sheet(item: $selectedUser) { user in
                    UserDetailView(user: user)
                        .presentationDetents([.large])
                        .preferredColorScheme(.dark)
                }
    }

    // MARK: - Users
    @ViewBuilder
    private var usersContent: some View {
        if viewModel.filteredUsers.isEmpty {
            VStack(spacing: 12) {
                Spacer().frame(height: 40)
                Image(systemName: "person.2")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.textHint)
                Text("Ulanyjy ýok")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        } else {
            ForEach(viewModel.filteredUsers) { user in
                UserCard(
                    user: user,
                    stats: viewModel.taskStats(for: user.id),
                    onDelete: { viewModel.deleteUser(id: user.id) },
                    onTap: { selectedUser = user }
                )
            }
        }
    }

    // MARK:  Invitations 
    @ViewBuilder
    private var invitationsContent: some View {
        if viewModel.incomingOffers.isEmpty {
            VStack(spacing: 12) {
                Spacer().frame(height: 40)
                Image(systemName: "envelope")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.textHint)
                Text("Çakylyk ýok")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
        } else {
            ForEach(viewModel.incomingOffers) { offer in
                InvitationCard(
                    offer: offer,
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
                .foregroundColor(selectedTab == tab ? .white : AppColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(selectedTab == tab ? AppColors.surfaceLight : Color.clear)
                .cornerRadius(8)
        }
    }
}

#Preview {
    UsersView()
        .preferredColorScheme(.dark)
}
