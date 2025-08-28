import SwiftUI
import SwiftData
import UserNotifications


enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var titleKey: LocalizedStringKey {
        switch self {
        case .system: return "settings_theme_system"
        case .light:  return "settings_theme_light"
        case .dark:   return "settings_theme_dark"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

@main
struct TollTrackerApp: App {
    @AppStorage("appAppearance") private var appAppearanceRaw: String = AppAppearance.system.rawValue
    @AppStorage("appLanguage") private var appLanguage = "en" // язык интерфейса

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    
    @Environment(\.scenePhase) private var scenePhase

    
    init() {
        
        NotificationCenter.default.post(name: Notification.Name("art.icon.loading.start"), object: nil)
        IconSettings.shared.attach()
    }

    
    
    var body: some Scene {
        WindowGroup {
            TabSettingsView{
                RootView()
                    .environment(\.locale, Locale(identifier: appLanguage)) // мгновенная смена языка
                    .preferredColorScheme(currentAppearance().colorScheme)
                
            }
            
                .onAppear {
                    OrientationGate.allowAll = false

                }
            
        }
        .modelContainer(for: [
            Vehicle.self, TollRoad.self, TollTariff.self,
            Trip.self, TollEntry.self
        ])
        
        
        
        
    }

    private func currentAppearance() -> AppAppearance {
        AppAppearance(rawValue: appAppearanceRaw) ?? .system
    }
    
    
    final class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            if OrientationGate.allowAll {
                return [.portrait, .landscapeLeft, .landscapeRight]
            } else {
                return [.portrait]
            }
        }
    }
    
    
    
    
    
}
