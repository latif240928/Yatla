// Sağ altta yüzen yuvarlak eylem düğmesi; güvenli alanın üzerinde kalır, yerleşim sınıfına göre boyutlanır (iPad’de daha geniş dokunma).
import SwiftUI

/// Özellik ekranlarında tekrar kullanılabilir dairesel FAB.
struct FloatingActionButton: View {
    let systemImage: String
    var foreground: Color = AppColors.textInverse
    var background: Color = AppColors.buttonActive
    var action: () -> Void

    @Environment(\.layout) private var layout

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: action) {
                    Image(systemName: systemImage)
                        .font(AppFonts.aestetico(size: layout.value(compact: 24, regular: 26, wide: 28),
                                                 weight: .semibold))
                        .foregroundColor(foreground)
                        .frame(width: layout.value(compact: 56, regular: 60, wide: 64),
                               height: layout.value(compact: 56, regular: 60, wide: 64))
                        .background(Circle().fill(background))
                        .shadow(color: background.opacity(0.35), radius: 16, y: 4)
                }
                .padding(.trailing, layout.value(compact: 20, regular: 24, wide: 32))
                .padding(.bottom, 8)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        FloatingActionButton(systemImage: "plus") { }
    }
}
