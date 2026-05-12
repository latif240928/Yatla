// Uygulama renk paleti (açık / koyu tema).
//
// Açık tema → krem + gökyüzü mavisi (sıcak + sakin)
// Koyu tema → derin lacivert + elektrik mavisi
//
// Tasarımcıların tek yerden ayarlaması için hex değerleri burada toplanır.
// Çağrı noktalarında anlamsal isimler (`textPrimary`, `surface` vb.) kullanın — satır içi hex yazmayın.
//
// Açık tema paleti özeti ↘
//   #FAF6EE   krem parşömen    → background
//   #FFFBF2   sıcak beyaz      → surface
//   #F1E9D9   bal rengi        → surfaceLight
//   #E0EAFF   gökyüzü tonu     → surfaceAlt
//   #1F2A4D   gece mürekkebi   → textPrimary
//   #5C6378   taş gri          → textSecondary
//   #4F8CFF   elektrik mavisi  → primary
//   #C8D9FF   bulut mavisi     → primaryLight

import SwiftUI

enum AppColors {

    // MARK: - Marka
    static let primary       = Color(light: "#4F8CFF", dark: "#7DA8FF")
    static let primaryLight  = Color(light: "#C8D9FF", dark: "#1E3A8A")
    static let secondary     = Color(light: "#36C5DC", dark: "#38BDF8")

    // MARK: - Arka plan ve yüzeyler
    static let background     = Color(light: "#FAF6EE", dark: "#0F172A")
    static let surface        = Color(light: "#FFFBF2", dark: "#1E293B")
    static let surfaceLight   = Color(light: "#F1E9D9", dark: "#334155")
    static let surfaceAlt     = Color(light: "#E0EAFF", dark: "#1E3A8A")
    static let surfaceElevated = Color(light: "#FFFFFF", dark: "#334155")

    // MARK: - Metin
    static let textPrimary   = Color(light: "#1F2A4D", dark: "#F8FAFC")
    static let textSecondary = Color(light: "#5C6378", dark: "#94A3B8")
    static let textHint      = Color(light: "#9CA0AE", dark: "#64748B")
    static let textInverse   = Color(light: "#FFFFFF", dark: "#0F172A")

    // MARK: - İşlevsel renkler
    static let error   = Color(light: "#E94957", dark: "#F87171")
    static let success = Color(light: "#3CB37A", dark: "#34D399")
    static let warning = Color(light: "#E89B3C", dark: "#FBBF24")
    static let info    = Color(light: "#4F8CFF", dark: "#60A5FA")

    // MARK: - Kenarlık ve ayırıcılar
    static let divider        = Color(light: "#E5DECC", dark: "#334155")
    static let border         = Color(light: "#D4CCB8", dark: "#475569")
    static let borderFocused  = Color(light: "#4F8CFF", dark: "#60A5FA")

    // MARK: - Renk geçişleri
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primary, Color(light: "#3A78EA", dark: "#3B82F6")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Outgoing message bubbles + primary buttons — bright sky ramp.
    static var messageFromMeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(light: "#5C9BFF", dark: "#3B82F6"),
                Color(light: "#3A78EA", dark: "#1D4ED8")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Soft diagonal wash used as the chat backdrop.
    static var chatBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(light: "#FAF6EE", dark: "#0B1220"),
                Color(light: "#F2EAD8", dark: "#0F172A"),
                Color(light: "#E0EAFF", dark: "#111A2E")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Hero gradient for splash + auth landing — cream above, sky below so
    /// a logo or title sits comfortably over the warm-to-cool transition.
    static var authBackgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(light: "#FFFBF2", dark: "#0B1220"),
                Color(light: "#F4ECDA", dark: "#0F172A"),
                Color(light: "#E0EAFF", dark: "#0E1B36")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Gölge
    static func shadowColor(opacity: Double = 0.08) -> Color {
        Color(light: "#1F2A4D", dark: "#000000").opacity(opacity)
    }

    // MARK: - Örtü (sayfa karartması, modal perde)
    static let overlay = Color(light: "#1F2A4D", dark: "#000000").opacity(0.32)

    // MARK: - Durum (çevrimiçi vb.)
    static let online  = Color(light: "#3CB37A", dark: "#34D399")
    static let offline = Color(light: "#9CA0AE", dark: "#64748B")

    // MARK: - Düğme durumları
    //
    // `buttonActive` is the **brand primary** — never a plain black/white.
    // Older code that grabbed `textPrimary` for a button background is wrong
    // and should migrate to `primary` / `messageFromMeGradient`.
    static let buttonActive       = primary
    static let buttonDanger       = error
    static let buttonSuccess      = success
    static let buttonDisabled     = Color(light: "#D9D2C0", dark: "#475569")
    static let buttonDisabledText = Color(light: "#9CA0AE", dark: "#64748B")

    // MARK: - Görev durumu renkleri
    static let statusDone       = success
    static let statusWaiting    = warning
    static let statusInProgress = primary
    static let statusRejected   = error
}
