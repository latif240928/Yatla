import SwiftUI

struct StatCard: View {
    let title: String
    let value: Int
    var color: Color = AppColors.primary

    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(AppFonts.aestetico(size: 32, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(AppFonts.caption1)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.divider, lineWidth: 1)
        )
        .shadow(color: AppColors.shadowColor(opacity: 0.04), radius: 8, y: 4)
    }
}
