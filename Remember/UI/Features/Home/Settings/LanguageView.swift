// UI/Features/Settings/LanguageView.swift
import SwiftUI

struct LanguageView: View {
    @ObservedObject var vm: SettingsViewModel
    @EnvironmentObject private var container: DIContainer
    @Environment(\.dismiss) private var dismiss

    private var lang: Language { vm.settings.selectedLanguage }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                    headerCard
                    optionsBlock
                    Spacer().frame(height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle(L10n.string(.languageTitle, language: lang))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(systemName: "globe")
                    .font(AppFonts.aestetico(size: 22))
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.string(.languageTitle, language: lang))
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text(L10n.string(.signInLine2, language: lang))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
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
            ForEach(Language.allCases) { lang in
                option(for: lang)
            }
        }
    }

    private func option(for option: Language) -> some View {
        let selected = vm.settings.selectedLanguage == option
        return Button {
            vm.selectLanguage(option)
        } label: {
            HStack(spacing: 14) {
                Text(option.flag)
                    .font(AppFonts.aestetico(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.displayName)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    Text(option.rawValue.uppercased())
                        .font(AppFonts.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(selected ? AppColors.primary : AppColors.divider, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected {
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
                        selected ? AppColors.primary.opacity(0.5) : AppColors.divider,
                        lineWidth: selected ? 2 : 1
                    )
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 6, y: 3)
        }
        .buttonStyle(PressedScaleStyle())
    }
}
