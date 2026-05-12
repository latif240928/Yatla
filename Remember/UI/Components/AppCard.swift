import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    var background: Color = AppColors.surface
    var borderColor: Color = AppColors.divider
    var borderWidth: CGFloat = 1
    var shadowRadius: CGFloat = 4
    var shadowOpacity: Double = 0.04
    
    init(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        background: Color = AppColors.surface,
        borderColor: Color = AppColors.divider,
        borderWidth: CGFloat = 1,
        shadowRadius: CGFloat = 4,
        shadowOpacity: Double = 0.04,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.background = background
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.shadowOpacity = shadowOpacity
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(
                color: AppColors.shadowColor(opacity: shadowOpacity),
                radius: shadowRadius,
                y: 2
            )
    }
}
