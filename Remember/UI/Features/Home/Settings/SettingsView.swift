// UI/Features/Settings/SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @StateObject var vm = SettingsViewModel()
    @EnvironmentObject var router: AppRouter

    private var lang: Language { vm.settings.selectedLanguage }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text(L10n.string(.settingsTitle, language: lang))
                            .font(AppFonts.largeTitle)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    ScrollView {
                        VStack(spacing: 18) {
                            profileCard
                            settingsList
                            logoutButton
                            Spacer().frame(height: 80)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear { vm.syncProfileFromSession() }
        }
    }

    // MARK: - Profil kartı
    //
    // Gerçek oturum açmış kimliği (kullanıcının kayıt sırasında girdiği ad + telefon)
    // gösterir; `SettingsViewModel.profile`'dan alınır ve `SessionStore.currentUser`'ı
    // yansıtır. Kullanıcı `ProfileView` içinde zaten bir avatar seçtiyse
    // onu da önizler.
    private var profileCard: some View {
        NavigationLink {
            ProfileView(vm: vm)
        } label: {
            HStack(spacing: 14) {
                avatar

                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.profile.name)
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(1)
                    Text(vm.profile.phone)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 6, y: 3)
        }
        .buttonStyle(PressedScaleStyle())
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.primary.opacity(0.25),
                            AppColors.primary.opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
            if let urlString = vm.profile.imageURL,
               let url = URL(string: urlString),
               let data = try? Data(contentsOf: url),
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
            } else {
                Text(vm.profile.name.prefix(2).uppercased())
                    .font(AppFonts.aestetico(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
        }
        .overlay(Circle().stroke(AppColors.surface, lineWidth: 3))
    }

    // MARK: - Ayarlar listesi
    //
    // Her satır kendi köşe yarıçapı kapsayıcısına sarılıdır (zaten `SettingsRow`
    // içinde), ancak çevresindeki kart yumuşak bir gölge + gruplama ekler;
    // böylece dört giriş tek bir blok olarak okunur.
    private var settingsList: some View {
        VStack(spacing: 10) {
            NavigationLink {
                StatsView(vm: vm)
            } label: {
                SettingsRow(
                    icon: "chart.bar.fill",
                    title: L10n.string(.settingsStats, language: lang),
                    color: .orange
                )
            }
            .buttonStyle(PressedScaleStyle())

            NavigationLink {
                LanguageView(vm: vm)
            } label: {
                SettingsRow(
                    icon: "globe",
                    title: L10n.string(.settingsLanguage, language: lang),
                    color: .blue
                )
            }
            .buttonStyle(PressedScaleStyle())

            NavigationLink {
                ThemeView(vm: vm)
            } label: {
                SettingsRow(
                    icon: "moon.fill",
                    title: L10n.string(.settingsTheme, language: lang),
                    color: .purple
                )
            }
            .buttonStyle(PressedScaleStyle())
        }
    }

    private var logoutButton: some View {
        Button(action: { vm.logout(router: router) }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.error.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(AppFonts.aestetico(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.error)
                }
                Text(L10n.string(.settingsLogout, language: lang))
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.error)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.error.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(AppColors.error.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 6, y: 3)
        }
        .buttonStyle(PressedScaleStyle())
    }
}

#Preview {
    SettingsView().environmentObject(AppRouter())
}
