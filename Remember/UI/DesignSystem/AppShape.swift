// Köşe yarıçapı, çizgi kalınlığı ve gölge için tek kaynak.
// Özellik görünümlerinde `cornerRadius(20)` sabitlemeyin; `AppShape.<rol>` kullanın —
// tasarım dili değişince tüm arayüz birlikte hareket etsin.
//
// Roller:
//   chip          – küçük haplar (süzgeç çipleri, rozetler)
//   button        – ana / ikincil düğmeler
//   input         – metin alanları, arama çubuğu
//   card          – liste satırları, özet paneller
//   sheetPanel    – `.sheet` / safeAreaInset içi yüzey
//   modalPanel    – grup halinde küçük pencereler (sessiz seçici, yorum düzenleyici)
//   avatar        – yuvarlak → geniş hap avatar (iPad)
//   tabBar        – sekme çubuğu kapsülü
//
// `LayoutMetrics.cardRadius(_:)` rol + boyut sınıfını `CGFloat`'e çözümler;
// çağrı yerinde tekrar tekrar dallanma yazmadan büyük ekranda yarıçap büyütülür.

import SwiftUI

enum AppShape {
    // MARK: - Sabit köşe yarıçapları (kompakt / iPhone)
    static let chip:       CGFloat = 14
    static let button:     CGFloat = 16
    static let input:      CGFloat = 16
    static let card:       CGFloat = 20
    static let sheetPanel: CGFloat = 22
    static let modalPanel: CGFloat = 22
    static let tabBar:     CGFloat = 32
    static let avatar:     CGFloat = 999    // capsule

    // MARK: - Çizgi kalınlıkları
    enum Stroke {
        static let hair:     CGFloat = 0.5
        static let regular:  CGFloat = 1
        static let focused:  CGFloat = 2
    }

    // MARK: - Yaygın roller için hazır şekiller
    static var chipShape:       RoundedRectangle { .init(cornerRadius: chip) }
    static var buttonShape:     RoundedRectangle { .init(cornerRadius: button) }
    static var inputShape:      RoundedRectangle { .init(cornerRadius: input) }
    static var cardShape:       RoundedRectangle { .init(cornerRadius: card) }
    static var sheetShape:      RoundedRectangle { .init(cornerRadius: sheetPanel) }
    static var modalShape:      RoundedRectangle { .init(cornerRadius: modalPanel) }
}

enum AppSpacing {
    // Horizontal page padding fall-backs (use `LayoutMetrics.gutter` when
    // the environment is available; these constants are for static contexts
    // such as previews or one-off helpers).
    static let pageGutterCompact: CGFloat = 20
    static let pageGutterRegular: CGFloat = 28
    static let pageGutterWide:    CGFloat = 36

    // Stack rhythm — keeps vertical breathing consistent.
    static let xs:  CGFloat = 4
    static let s:   CGFloat = 8
    static let m:   CGFloat = 12
    static let l:   CGFloat = 16
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Yerleşime duyarlı yarıçap yardımcısı
//
// Roles map to base values from `AppShape`, and the helper bumps them on
// regular/wide layouts so iPad cards don't look anemic. Use this in views
// that already read `@Environment(\.layout)`.
extension LayoutMetrics {
    enum ShapeRole {
        case chip, button, input, card, sheetPanel, modalPanel, tabBar
    }

    func radius(_ role: ShapeRole) -> CGFloat {
        let base: CGFloat = {
            switch role {
            case .chip:       return AppShape.chip
            case .button:     return AppShape.button
            case .input:      return AppShape.input
            case .card:       return AppShape.card
            case .sheetPanel: return AppShape.sheetPanel
            case .modalPanel: return AppShape.modalPanel
            case .tabBar:     return AppShape.tabBar
            }
        }()
        switch layoutClass {
        case .compact: return base
        case .regular: return base + 2
        case .wide:    return base + 4
        }
    }

    /// Recommended max width for an Auth-style centered form. We don't want
    /// the form to span the whole iPad screen — it should sit in a 460-540
    /// pt column.
    var authFormMaxWidth: CGFloat {
        switch layoutClass {
        case .compact: return .infinity
        case .regular: return 520
        case .wide:    return 560
        }
    }
}
