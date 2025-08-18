import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainTabs()
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }
}

struct MainTabs: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label(LocalizedStringKey("tab_today"), systemImage: "sun.max") }
            TripsView()
                .tabItem { Label(LocalizedStringKey("tab_trips"), systemImage: "car.fill") }
            DirectoryView()
                .tabItem { Label(LocalizedStringKey("tab_directory"), systemImage: "list.bullet.rectangle") }
            ReportsView()
                .tabItem { Label(LocalizedStringKey("tab_reports"), systemImage: "chart.bar") }
            SettingsView()
                .tabItem { Label(LocalizedStringKey("tab_settings"), systemImage: "gear") }
        }
    }
}
