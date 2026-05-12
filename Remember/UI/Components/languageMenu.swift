// UI/Components/LanguageMenu.swift
//
// Her Kimlik Doğrulama ekranının sağ üstünde kullanılan kompakt dil değiştirici.
// Hapa dokunulduğunda, dört dilin ve tam adlarının açıkça görünebildiği
// özel bir popover tarzı sayfa açılır — önceki `Menu` tabanlı uygulama,
// her satırın metnini sistem menüsünün kendi arka planına karşı
// `AppColors.textPrimary` ile işliyordu ve bu da iOS 17'de açık temalarda
// etiketleri görünmez bırakıyordu.

import SwiftUI

struct LanguageMenu: View {
    @EnvironmentObject private var container: DIContainer
    @State private var isOpen: Bool = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            isOpen.toggle()
        } label: {
            HStack(spacing: 6) {
                Text(container.appSettings.selectedLanguage.flag)
                    .font(.system(size: 16))
                Text(container.appSettings.selectedLanguage.menuCode)
                    .font(AppFonts.aestetico(size: 13, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                    .rotationEffect(.degrees(isOpen ? 180 : 0))
                    .animation(.easeInOut(duration: 0.18), value: isOpen)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule().fill(AppColors.surface)
            )
            .overlay(
                Capsule().stroke(AppColors.divider, lineWidth: AppShape.Stroke.regular)
            )
            .shadow(color: AppColors.shadowColor(opacity: 0.06), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .popover(isPresented: $isOpen, arrowEdge: .top) {
            languageList
                .presentationCompactAdaptation(.popover)
        }
    }

    private var languageList: some View {
        VStack(spacing: 0) {
            ForEach(Language.allCases) { lang in
                Button {
                    container.persistLanguage(lang)
                    isOpen = false
                } label: {
                    HStack(spacing: 12) {
                        Text(lang.flag)
                            .font(.system(size: 22))
                            .frame(width: 30, height: 30)
                            .background(AppColors.surfaceLight)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 1) {
                            // Tam okunabilir ad — daha önce sistem menüsünün
                            // ön plan renk kuralları tarafından gizleniyordu.
                            Text(lang.displayName)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                            Text(lang.menuCode)
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textHint)
                        }
                        Spacer()
                        if container.appSettings.selectedLanguage == lang {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(minWidth: 220)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if lang != Language.allCases.last {
                    Divider()
                        .background(AppColors.divider)
                        .padding(.leading, 56)
                }
            }
        }
        .padding(.vertical, 8)
        .background(AppColors.surface)
    }
}

#Preview("Language Menu") {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VStack {
            HStack {
                Spacer()
                LanguageMenu()
                    .padding()
            }
            Spacer()
        }
    }
    .environmentObject(DIContainer.shared)
}
