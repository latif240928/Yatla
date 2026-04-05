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
            .background(AppColors.error.opacity(0.1))
            .cornerRadius(12)
        }
    }
}
