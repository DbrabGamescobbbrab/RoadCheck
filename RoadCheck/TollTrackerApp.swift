import SwiftUI
import SwiftData

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

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.locale, Locale(identifier: appLanguage)) // мгновенная смена языка
                .preferredColorScheme(currentAppearance().colorScheme)
        }
        .modelContainer(for: [
            Vehicle.self, TollRoad.self, TollTariff.self,
            Trip.self, TollEntry.self
        ])
    }

    private func currentAppearance() -> AppAppearance {
        AppAppearance(rawValue: appAppearanceRaw) ?? .system
    }
}
