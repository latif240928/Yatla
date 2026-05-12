// Uygulama giriş noktası: ana pencere ve bildirim delegesi.
import SwiftUI
import UserNotifications

@main
struct YatlaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Push bildirim izinleri, cihaz jetonu ve ön planda bildirim davranışını yönetir.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Notification center delegate ayarla
        UNUserNotificationCenter.current().delegate = self

        // Push notification izinlerini iste
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } catch {
                print("Notification authorization failed: \(error)")
            }
        }

        return true
    }

    // Push token alındığında
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")

        // Jetonu sunucuya kaydet (`DIContainer` @MainActor olduğu için ana iş parçacığında).
        Task { @MainActor in
            do {
                let di = DIContainer.shared
                let userId = di.session.currentUser.id
                try await di.registerDeviceTokenUseCase.execute(token: token, for: userId)
            } catch {
                print("Failed to register device token: \(error)")
            }
        }
    }

    // Push token kaydı başarısız
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    // Bildirim geldiğinde (app açıkken)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // Bildirime tıklandığında
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Bildirim tipine göre navigation yap
        if let taskId = userInfo["taskId"] as? String {
            // Görev detayına git
            print("Navigate to task: \(taskId)")
        }

        completionHandler()
    }
}
