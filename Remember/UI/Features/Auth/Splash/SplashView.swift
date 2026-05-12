// UI/Features/Auth/Splash/SplashView.swift

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            AppColors.authBackgroundGradient.ignoresSafeArea()

            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                )
                .scaleEffect(viewModel.isAnimating ? 1.0 : 0.4)
                .opacity(viewModel.isAnimating ? 1.0 : 0.0)
                .shadow(color: Color.black.opacity(0.2), radius: 30, y: 12)
                .animation(.spring(response: 0.7, dampingFraction: 0.7), value: viewModel.isAnimating)
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
