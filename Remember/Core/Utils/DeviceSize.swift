//  DeviceSize.swift — iPhone / iPad için duyarlı yerleşim temelleri.
//
//  Kullanım:
//    @Environment(\.layout) private var layout
//    .padding(.horizontal, layout.gutter)
//    if layout.isWide { ... yalnızca iPad sütunu ... }
//
//  Boyuta uyum sağlayan görünümler `layout`'u ortamdan okumalıdır;
//  `UIScreen.main` çoklu pencereli iPad'de güvenilir değildir.

import SwiftUI

// MARK: - Cihaz boyutu grupları

enum LayoutClass {
    case compact   // Dikey iPhone ve küçük telefonlar
    case regular   // Büyük iPhone yatay, iPad tek sütun dikey
    case wide      // iPad yatay, geniş iPad dikey

    static func from(width: CGFloat) -> LayoutClass {
        switch width {
        case ..<600:   return .compact
        case 600..<900: return .regular
        default:        return .wide
        }
    }
}

// MARK: - Yerleşim ölçüleri

struct LayoutMetrics {
    let width: CGFloat
    let layoutClass: LayoutClass

    var isCompact: Bool { layoutClass == .compact }
    var isRegular: Bool { layoutClass == .regular }
    var isWide: Bool    { layoutClass == .wide }

    /// Dış yatay sayfa dolgusu ("gutter").
    var gutter: CGFloat {
        switch layoutClass {
        case .compact: return 16
        case .regular: return 24
        case .wide:    return 32
        }
    }

    /// Kardeş öğeler arası iç boşluk (vstack/hstack varsayılanı).
    var spacing: CGFloat {
        switch layoutClass {
        case .compact: return 12
        case .regular: return 16
        case .wide:    return 20
        }
    }

    /// Büyük iPad'lerde maksimum okunabilir içerik genişliği — kartların
    /// aşırı geniş uzamasını önler.
    var contentMaxWidth: CGFloat {
        switch layoutClass {
        case .compact: return .infinity
        case .regular: return 720
        case .wide:    return 900
        }
    }

    /// Izgara düzenleri için sütun sayısı (görev kartları, kullanıcı kartları).
    var gridColumns: Int {
        switch layoutClass {
        case .compact: return 1
        case .regular: return 2
        case .wide:    return 3
        }
    }

    /// Kart köşe yarıçapı — görsel denge için büyük ekranlarda biraz daha fazla.
    var cardCornerRadius: CGFloat {
        switch layoutClass {
        case .compact: return 16
        case .regular: return 20
        case .wide:    return 24
        }
    }

    /// Yerleşim sınıfına göre gruplanmış bir değer seç.
    func value<T>(compact: T, regular: T? = nil, wide: T? = nil) -> T {
        switch layoutClass {
        case .compact: return compact
        case .regular: return regular ?? compact
        case .wide:    return wide ?? regular ?? compact
        }
    }
}

// MARK: - Ortam anahtarı

private struct LayoutMetricsKey: EnvironmentKey {
    static let defaultValue = LayoutMetrics(width: 393, layoutClass: .compact)
}

extension EnvironmentValues {
    var layout: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

// MARK: - Kök enjektor

/// Kök yakınında kullanılabilir genişliği bir kez okuyup `LayoutMetrics`'i ortama enjekte eder;
/// böylece derin görünümler kendi `GeometryReader`'ına ihtiyaç duymadan uyum sağlar.
struct LayoutReader<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            let metrics = LayoutMetrics(
                width: proxy.size.width,
                layoutClass: LayoutClass.from(width: proxy.size.width)
            )
            content()
                .environment(\.layout, metrics)
        }
    }
}

// MARK: - Görünüm yardımcıları

extension View {
    /// iPad'de uzamaması için kart/metin kapsayıcılarını sınırla.
    func readableContentWidth() -> some View {
        modifier(ReadableContentWidthModifier())
    }
}

private struct ReadableContentWidthModifier: ViewModifier {
    @Environment(\.layout) private var layout

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: layout.contentMaxWidth)
            .frame(maxWidth: .infinity)
    }
}
