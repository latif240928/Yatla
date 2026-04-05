// UI/Features/Settings/LanguageView.swift
import SwiftUI

struct LanguageView: View {
    @ObservedObject var vm: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ForEach(Language.allCases) { lang in
                    Button {
                        vm.selectLanguage(lang)          
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
                    } label: {
                        HStack(spacing: 14) {
                            Text(lang.flag)
                                .font(.system(size: 28))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(lang.displayName)
                                    .font(AppFonts.body)
                                    .foregroundColor(.white)
                                Text(lang.rawValue.uppercased())
                                    .font(AppFonts.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            if vm.settings.selectedLanguage == lang {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            vm.settings.selectedLanguage == lang
                            ? AppColors.primary.opacity(0.1)
                            : Color.clear
                        )
                    }
                    Divider().background(AppColors.divider).padding(.horizontal, 20)
                }

                Spacer()
            }
            .padding(.top, 12)
        }
        .navigationTitle("Dil")
        .navigationBarTitleDisplayMode(.inline)
    }
}
