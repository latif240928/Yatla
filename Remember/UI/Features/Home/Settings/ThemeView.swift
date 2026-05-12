// UI/Features/Settings/ThemeView.swift
import SwiftUI

struct ThemeView: View {
    @ObservedObject var vm: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    private var lang: Language { vm.settings.selectedLanguage }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    headerCard
                    optionsBlock
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle(L10n.string(.themeTitle, language: lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Ekranın çıplak bir listeyle açılmaması için samimi bir tanıtım kartı.
    private var headerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.primary.opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(systemName: "paintbrush.pointed.fill")
                    .font(AppFonts.aestetico(size: 22))
                    .foregroundColor(AppColors.primary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.string(.themeIntroTitle, language: lang))
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text(L10n.string(.themeIntroSubtitle, language: lang))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
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

    private var optionsBlock: some View {
        VStack(spacing: 10) {
            themeOption(
                title: L10n.string(.themeDark, language: lang),
                subtitle: L10n.string(.themeDarkSubtitle, language: lang),
                icon: "moon.fill",
                color: .indigo,
                isSelected: vm.settings.isDarkMode
            ) {
                if !vm.settings.isDarkMode { vm.toggleTheme() }
            }

            themeOption(
                title: L10n.string(.themeLight, language: lang),
                subtitle: L10n.string(.themeLightSubtitle, language: lang),
                icon: "sun.max.fill",
                color: .yellow,
                isSelected: !vm.settings.isDarkMode
            ) {
                if vm.settings.isDarkMode { vm.toggleTheme() }
            }
        }
    }

    private func themeOption(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(AppFonts.aestetico(size: 22))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    Text(subtitle)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? AppColors.primary.opacity(0.5) : AppColors.divider,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 6, y: 3)
        }
        .buttonStyle(PressedScaleStyle())
    }
}
