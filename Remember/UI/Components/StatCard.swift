import SwiftUI
// MARK: - StatCard
struct StatCard: View {
    let title: String
    let value: Int
    var color: Color = AppColors.primary

    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}
