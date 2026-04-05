// UI/Features/Auth/Splash/SplashViewModel.swift
import SwiftUI
import Combine

@MainActor
final class SplashViewModel: ObservableObject {
    @Published var isAnimating = false

    /// 2 saniye bekleyip router'a haber ver
    func startSplash(router: AppRouter) {
        withAnimation(.easeIn(duration: 0.4)) {
            isAnimating = true
        }

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            router.handleSplashFinished()
        }
    }
}
