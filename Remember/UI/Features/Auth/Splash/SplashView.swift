// UI/Features/Auth/Splash/SplashView.swift

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            AppColors.authBackgroundGradient.ignoresSafeArea()

            Image("appLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 160)
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .scaleEffect(viewModel.isAnimating ? 1.2 : 0.5)
                .opacity(viewModel.isAnimating ? 1.0 : 0.3)
                .shadow(color: AppColors.primary.opacity(0.3), radius: 40, y: 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            viewModel.startSplash(router: router)
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppRouter())
}
