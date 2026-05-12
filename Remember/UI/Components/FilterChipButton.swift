// Üst süzgeçler için hap şeklinde düğme (departman, durum vb.).
// `HomeView`, `CreateTasksView`, `UsersView` içindeki tekrarlayan `HStack { Text … ok … }` yerine kullanılır.
//
// `Leading` ile durum noktası, bayrak vb. eklenir.
import SwiftUI

/// Filtre çipi düğmesi.
struct FilterChipButton<Leading: View>: View {

    /// Görsel sıkılık.
    /// - `compact`  → küçük araç çubuğu stili (Home / CreateTasks üst çubuğu)
    /// - `regular`  → orta boy (varsayılan)
    /// - `prominent`→ büyük, title3 yazı tipi (eski görünüm)
    enum Size { case compact, regular, prominent }

    let title: String
    var size: Size = .compact
    var titleFont: Font?
    var trailingSystemImage: String = "chevron.down"
    let leading: Leading
    let action: () -> Void

    init(
        title: String,
        size: Size = .compact,
        titleFont: Font? = nil,
        trailingSystemImage: String = "chevron.down",
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        action: @escaping () -> Void
    ) {
        self.title = title
        self.size = size
        self.titleFont = titleFont
        self.trailingSystemImage = trailingSystemImage
        self.leading = leading()
        self.action = action
    }

    private var resolvedFont: Font {
        if let titleFont { return titleFont }
        switch size {
        case .compact:    return AppFonts.subheadline
        case .regular:    return AppFonts.body
        case .prominent:  return AppFonts.title3
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .compact:    return 12
        case .regular:    return 14
        case .prominent:  return 16
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .compact:    return 8
        case .regular:    return 10
        case .prominent:  return 12
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .compact:    return 14
        case .regular:    return 16
        case .prominent:  return 18
        }
    }

    private var trailingIconSize: CGFloat {
        switch size {
        case .compact:    return 12
        case .regular:    return 14
        case .prominent:  return 15
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                leading
                Text(title)
                    .font(resolvedFont)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Image(systemName: trailingSystemImage)
                    .font(.system(size: trailingIconSize, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(AppColors.surface)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.divider, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
