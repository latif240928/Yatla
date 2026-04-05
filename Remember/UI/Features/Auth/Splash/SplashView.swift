// UI/Features/Auth/Splash/SplashView.swift
import SwiftUI

struct SplashView: View {
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = SplashViewModel()
    
    var body: some View {
            ZStack {
                // Arka plan
                AppColors.background
                    .ignoresSafeArea()
                
                // Logo ortada
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180)
                    .scaleEffect(viewModel.isAnimating ? 1.5 : 0.5)
                    .opacity(viewModel.isAnimating ? 1.0 : 0.5)
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
