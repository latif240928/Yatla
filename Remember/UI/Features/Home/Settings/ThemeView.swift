
// UI/Features/Settings/ThemeView.swift
import SwiftUI

struct ThemeView: View {
    @ObservedObject var vm: SettingsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 12) {
                themeOption(
                    title: "Garaňky tema",
                    subtitle: "Gözüňe ýakymly garaňky reňk",
                    icon: "moon.fill",
                    color: .indigo,
                    isSelected: vm.settings.isDarkMode
                ) {
                    if !vm.settings.isDarkMode { vm.toggleTheme() }
                }

                themeOption(
                    title: "Açyk tema",
                    subtitle: "Ýagty we aýdyň reňk",
                    icon: "sun.max.fill",
                    color: .yellow,
                    isSelected: !vm.settings.isDarkMode
                ) {
                    if vm.settings.isDarkMode { vm.toggleTheme() }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .navigationTitle("Tema")
        .navigationBarTitleDisplayMode(.inline)
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
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(AppFonts.body)
                        .foregroundColor(.white)
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? AppColors.primary.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
    }
}
