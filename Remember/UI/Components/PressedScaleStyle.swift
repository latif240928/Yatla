// UI/Components/PressedScaleStyle.swift
//
// Herhangi bir dokunulabilir yüzeye hafif bir "basma" tepkisi
// (ölçekleme + hafif dokunsal geri bildirim) veren yeniden kullanılabilir
// buton stili. Sohbet satırları, liste kartları vb. yerlerde kullanılır.
import SwiftUI

struct PressedScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.97
    var hapticOnPress: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.32, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed && hapticOnPress {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

extension ButtonStyle where Self == PressedScaleStyle {
    static var pressedScale: PressedScaleStyle { PressedScaleStyle() }
}
