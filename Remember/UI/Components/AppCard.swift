import SwiftUI

struct AppCard<Content: View>: View {
    let content: Content
    
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    var background: Color = AppColors.surface
    var borderColor: Color = AppColors.divider
    var borderWidth: CGFloat = 1
    
    init(
        cornerRadius: CGFloat = 16,
        padding: CGFloat = 16,
        background: Color = AppColors.surface,
        borderColor: Color = AppColors.divider,
        borderWidth: CGFloat = 1,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.background = background
        self.borderColor = borderColor
        self.borderWidth = borderWidth
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
    }
}
