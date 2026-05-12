import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var style: ButtonStyle = .primary
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case danger
        case success
        
        var activeColor: Color {
            switch self {
            case .primary: return AppColors.buttonActive
            case .danger: return AppColors.error
            case .success: return AppColors.success
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(AppColors.textInverse)
                }
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textInverse)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isEnabled ? style.activeColor : AppColors.buttonDisabled)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isEnabled ? Color.clear : AppColors.divider,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isEnabled ? style.activeColor.opacity(0.25) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .disabled(!isEnabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Dowam et", isEnabled: true) {}
        PrimaryButton(title: "Dowam et", isEnabled: false) {}
        PrimaryButton(title: "Ýatýrmak", style: .danger) {}
        PrimaryButton(title: "Kabul etmek", style: .success) {}
    }
    .padding()
    .background(AppColors.background)
}
