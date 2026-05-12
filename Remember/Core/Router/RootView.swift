// Kök görünüm: splash → kimlik doğrulama veya ana uygulama akışını seçer.
import SwiftUI
import Combine

struct RootView: View {
    @StateObject private var router    = AppRouter()
    @StateObject private var container = DIContainer.shared

    var body: some View {
        LayoutReader {
            Group {
                switch router.appState {
                case .splash:
                    SplashView()
                        .environmentObject(router)

                case .auth:
                    NavigationStack(path: $router.authPath) {
                        RegistrationView()
                            .navigationDestination(for: AuthRoute.self) { route in
                                switch route {
                                case .registration:
                                    RegistrationView()
                                case .sms(let phone):
                                    SMSVerificationView(phoneNumber: phone)
                                case .accountSetup(let token):
                                    AccountSetupView(token: token)
                                case .signIn:
                                    SignInView()
                                }
                            }
                    }
                    .environmentObject(router)
                    .environmentObject(container)

                case .home:
                    HomeView()
                        .environmentObject(router)
                        .environmentObject(container)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: router.appState)
            .preferredColorScheme(container.appSettings.isDarkMode ? .dark : .light)
            // DEBUG: API ortamı ve sunucu erişilebilirliği için yüzen tanılama rozeti.
            .overlay(alignment: .topTrailing) {
                #if DEBUG
                DebugAPIBadge()
                    .padding(.top, 50)
                #endif
            }
        }
    }
}
