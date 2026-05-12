import SwiftUI

struct LogoutButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Çykyş")
                Spacer()
            }
            .foregroundColor(AppColors.error)
            .padding()
            .background(AppColors.error.opacity(0.08))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.error.opacity(0.2), lineWidth: 1)
            )
        }
    }
}
