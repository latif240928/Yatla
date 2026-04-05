import SwiftUI

// MARK: - PrimaryButton
// Programmanyn esasy bottony her yerde ulanylyp biliner

struct PrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var style: ButtonStyle = .primary
    let action: () -> Void
    
    enum ButtonStyle {
        case primary    // Cyan
        case danger     // Gyzyl
        case success    // Yaşyl
        
        var activeColor: Color {
            switch self {
            case .primary: return AppColors.buttonActive
            case .danger: return AppColors.buttonDanger
            case .success: return AppColors.buttonSuccess
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isEnabled ? style.activeColor : AppColors.buttonDisabled)
            )
            .shadow(
                color: isEnabled ? style.activeColor.opacity(0.3) : .clear,
                radius: 8, x: 0, y: 4
            )
        }
        .disabled(!isEnabled || isLoading)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

// MARK: - Preview
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
