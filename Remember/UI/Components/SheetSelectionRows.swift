// Alt sayfa listelerinde ortak satır ve ayırıcı bileşenleri (departman/durum seçicileri vb.).
import SwiftUI

/// Dolgulu satırlarla hizalı yatay ayırıcı.
struct SheetInsetDivider: View {
    var horizontalInset: CGFloat = 20

    var body: some View {
        Divider()
            .background(AppColors.divider)
            .padding(.horizontal, horizontalInset)
    }
}

/// Dokunulabilir tek satır — isteğe bağlı baştaki nokta / SF Symbol, başlık, seçiliyken onay işareti.
struct SheetCheckmarkOptionRow: View {

    enum RowLeading {
        case none
        case statusDot(Color)
        /// Sabit genişlikli simge yuvası (varsayılanlar `DepartmentSheet` / Görev Oluşturma seçicisiyle eşleşir).
        case symbol(name: String, foreground: Color = AppColors.primary, width: CGFloat = 20)
    }

    var leading: RowLeading = .none
    let title: String
    var titleFont: Font = AppFonts.body
    var horizontalInset: CGFloat = 20
    var verticalPadding: CGFloat = 14
    let isSelected: Bool
    let action: () -> Void

    private var innerSpacing: CGFloat {
        switch leading {
        case .none: return 0
        case .statusDot, .symbol: return 12
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: innerSpacing) {
                leadingView

                Text(title)
                    .font(titleFont)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal, horizontalInset)
            .padding(.vertical, verticalPadding)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var leadingView: some View {
        switch leading {
        case .none:
            EmptyView()
        case .statusDot(let color):
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
        case .symbol(let name, let foreground, let width):
            Image(systemName: name)
                .foregroundColor(foreground)
                .frame(width: width)
        }
    }
}
