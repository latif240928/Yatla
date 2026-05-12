// UI/Components/AuthScreenScaffold.swift
//
// Tüm Kimlik Doğrulama ekranları (Kayıt, Giriş, SMS Doğrulama,
// Hesap Kurulumu) tarafından paylaşılan tek yerleşim kabuğu.
// Bunu standartlaştırmak bize şunları sağlar:
//   • Gradyan arka plan + güvenli alan yönetimini tek yerden kontrol.
//   • Otomatik duyarlı boyutlandırma — iç sütun iPhone'da ekran
//     genişliğine, iPad/Mac'te ~520pt'ye daralır.
//   • Tutarlı bir üst satır (sağda dil menüsü, solda isteğe bağlı
//     geri butonu).
//   • Her zaman gizlilik satırını gösteren tutarlı bir alt bilgi.
//
// Görsel yapı:
//   ┌──────────────── ZStack (gradyan arka plan) ──────────┐
//   │  ┌── üst satır ──┐                                   │
//   │  │ geri  boşluk  DilMenüsü                           │
//   │  └────────────────┘                                   │
//   │                                                       │
//   │  ScrollView ─ ortalanmış sütun (maks genişlik sınırlı)│
//   │  │ <kullanıcı tarafından sağlanan içerik>             │
//   │  └────────────────────────────────────────────────────┘
//   │                                                       │
//   │  gizlilik alt bilgisi (isteğe bağlı)                  │
//   └───────────────────────────────────────────────────────┘

import SwiftUI

struct AuthScreenScaffold<Content: View>: View {
    @Environment(\.layout) private var layout
    @EnvironmentObject private var container: DIContainer

    let showsBackButton: Bool
    let onBack: (() -> Void)?
    let content: () -> Content

    init(
        showsBackButton: Bool = false,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showsBackButton = showsBackButton
        self.onBack = onBack
        self.content = content
    }

    private var lang: Language { container.appSettings.selectedLanguage }

    var body: some View {
        ZStack {
            AppColors.authBackgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, layout.gutter)
                    .padding(.top, 6)
                    .padding(.bottom, 4)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Orta sütun — iPad'de sınırlandırılmış, böylece
                        // form 1024pt'ye yayılmaz.
                        content()
                            .frame(maxWidth: layout.authFormMaxWidth)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, layout.gutter)
                            .padding(.top, layout.spacing)
                            .padding(.bottom, AppSpacing.xl)
                    }
                    .frame(maxWidth: .infinity, minHeight: 0)
                }

                Text(L10n.string(.privacyFooter, language: lang))
                    .font(AppFonts.caption2)
                    .foregroundColor(AppColors.textHint)
                    .padding(.bottom, AppSpacing.l)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Üst alan

    private var header: some View {
        HStack(alignment: .center, spacing: 0) {
            if showsBackButton, let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 36, height: 36)
                        .background(AppColors.surface)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(AppColors.divider, lineWidth: AppShape.Stroke.regular)
                        )
                        .shadow(color: AppColors.shadowColor(opacity: 0.05), radius: 6, y: 2)
                }
                .buttonStyle(.plain)
            }
            Spacer(minLength: 0)
            LanguageMenu()
        }
    }
}
