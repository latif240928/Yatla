// Core/Router/AppRouter.swift
import SwiftUI
import Combine

enum AuthRoute: Hashable {
    case registration
    case sms(phoneNumber: String)
    case signIn(phoneNumber: String)
}

enum AppState {
    case splash
    case auth
    case home
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var appState: AppState = .splash
    @Published var authPath: NavigationPath = NavigationPath()

    func handleSplashFinished() {
        if KeychainService.shared.isLoggedIn {
            appState = .home
        } else {
            appState = .auth
        }
    }

    func navigateToSMS(phoneNumber: String) {
        authPath.append(AuthRoute.sms(phoneNumber: phoneNumber))
    }

    func navigateToSignIn(phoneNumber: String) {
        authPath.append(AuthRoute.signIn(phoneNumber: phoneNumber))
    }

    func handleLoginSuccess(token: String) {
        KeychainService.shared.saveToken(token)
        authPath = NavigationPath()
        appState = .home
    }

    func navigateToHome() {
        authPath = NavigationPath()
        appState = .home
    }

    func logout() {
        KeychainService.shared.deleteToken()
        authPath = NavigationPath()
        appState = .auth
    }
}
