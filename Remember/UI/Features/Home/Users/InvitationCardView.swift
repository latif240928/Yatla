import SwiftUI
struct InvitationCardView: View {
    let user: User
    let date: String
    var onAccept: () -> Void
    var onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle().fill(AppColors.primary.opacity(0.2)).frame(width: 44, height: 44)
                    Text(user.name.prefix(1).uppercased()).foregroundColor(AppColors.primary)
                }
                VStack(alignment: .leading) {
                    Text(user.name).font(AppFonts.headline).foregroundColor(.white)
                    Text(user.phone).font(AppFonts.caption1).foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("UI Design").font(AppFonts.caption2).foregroundColor(AppColors.textHint)
                    Text(date).font(AppFonts.caption2).foregroundColor(AppColors.textHint)
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onReject) {
                    Text("Ýatyrmak")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                Button(action: onAccept) {
                    Text("Kabul etmek")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(8)
                }
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}
