// UI/Features/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @StateObject var vm = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text("Sazlamalar")
                            .font(AppFonts.largeTitle)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    ScrollView {
                        VStack(spacing: 12) {

                            profileHeader

                            Divider()
                                .background(AppColors.divider)
                                .padding(.horizontal, 20)

                            VStack(spacing: 8) {
                                NavigationLink {
                                    ProfileView(vm: vm)
                                        .preferredColorScheme(.dark)
                                } label: {
                                    SettingsRow(
                                        icon: "person.fill",
                                        title: "Profil",
                                        color: .cyan
                                    )
                                }
                                .buttonStyle(.plain)

                                NavigationLink {
                                    StatsView(vm: vm)
                                        .preferredColorScheme(.dark)
                                } label: {
                                    SettingsRow(
                                        icon: "chart.bar.fill",
                                        title: "Statistika",
                                        color: .orange
                                    )
                                }
                                .buttonStyle(.plain)

                                NavigationLink {
                                    LanguageView(vm: vm)
                                        .preferredColorScheme(.dark)
                                } label: {
                                    SettingsRow(
                                        icon: "globe",
                                        title: "Dil",
                                        color: .blue
                                    )
                                }
                                .buttonStyle(.plain)

                                NavigationLink {
                                    ThemeView(vm: vm)
                                        .preferredColorScheme(.dark)
                                } label: {
                                    SettingsRow(
                                        icon: "moon.fill",
                                        title: "Tema",
                                        color: .purple
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)

                            Divider()
                                .background(AppColors.divider)
                                .padding(.horizontal, 20)

                            Button(action: { vm.logout() }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red.opacity(0.2))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red)
                                    }
                                    Text("Çykmak")
                                        .font(AppFonts.body)
                                        .foregroundColor(.red)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.red.opacity(0.4))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppColors.surface)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 100) 
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.dark)
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 60, height: 60)
                Image(systemName: "person.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.primary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.profile.name)
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
                Text(vm.profile.phone)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

#Preview {
    SettingsView().preferredColorScheme(.dark)
}
