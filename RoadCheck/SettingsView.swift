import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var ctx

    @AppStorage("homeCurrency") private var homeCurrency = "USD"
    @AppStorage("monthlyLimit") private var monthlyLimit = 0
    @AppStorage("appAppearance") private var appAppearanceRaw = AppAppearance.system.rawValue
    @AppStorage("appLanguage") private var appLanguage = "en"
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = true

    // Focus для кнопки Done
    @FocusState private var currencyFocused: Bool
    @FocusState private var limitFocused: Bool

    private let privacyURL = URL(string: "https://www.freeprivacypolicy.com/live/5113cd18-070b-4a18-9c95-189580545a9d")!

    var body: some View {
        Form {
            // Тема
            Section(LocalizedStringKey("settings_theme")) {
                Picker(LocalizedStringKey("settings_theme"), selection: $appAppearanceRaw) {
                    ForEach(AppAppearance.allCases) { ap in
                        Text(ap.titleKey).tag(ap.rawValue)
                    }
                }
            }

            // Язык
            Section(LocalizedStringKey("settings_language")) {
                Picker(LocalizedStringKey("settings_language"), selection: $appLanguage) {
                    Text(LocalizedStringKey("lang_en")).tag("en")
                    Text(LocalizedStringKey("lang_fr")).tag("fr")
                    Text(LocalizedStringKey("lang_es")).tag("es")
                    Text(LocalizedStringKey("lang_it")).tag("it")
                    Text(LocalizedStringKey("lang_pt")).tag("pt")
                }
            }

            // Валюта/лимит с кнопкой Done на клавиатуре
            Section(LocalizedStringKey("settings_currency")) {
                TextField(
                    LocalizedStringKey("settings_currency"),
                    text: $homeCurrency,
                    prompt: Text(LocalizedStringKey("currency_ph"))
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($currencyFocused)
                .submitLabel(.done)

                TextField(
                    LocalizedStringKey("settings_monthly_limit"),
                    value: $monthlyLimit, format: .number
                )
                .keyboardType(.numberPad)
                .focused($limitFocused)
            }
            .toolbar {
                // Кнопка Done для любого поля этой секции
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(LocalizedStringKey("keyboard_done")) {
                        currencyFocused = false
                        limitFocused = false
                    }
                }
            }

            // About + Privacy
            Section(LocalizedStringKey("settings_about")) {
                Text(LocalizedStringKey("settings_about_text"))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button(LocalizedStringKey("settings_privacy")) {
                    UIApplication.shared.open(privacyURL, options: [:], completionHandler: nil)
                }
            }

            // Сброс всего
            Section {
                Button(role: .destructive) {
                    resetAll()
                } label: {
                    Text(LocalizedStringKey("reset_all"))
                }
            }
        }
        .navigationTitle(LocalizedStringKey("settings_title"))
    }

    private func resetAll() {
        // Стереть все данные SwiftData
        do {
            try ctx.transaction {
                let v = try ctx.fetch(FetchDescriptor<Vehicle>())
                let r = try ctx.fetch(FetchDescriptor<TollRoad>())
                let t = try ctx.fetch(FetchDescriptor<TollTariff>())
                let trips = try ctx.fetch(FetchDescriptor<Trip>())
                let entries = try ctx.fetch(FetchDescriptor<TollEntry>())
                entries.forEach { ctx.delete($0) }
                trips.forEach { ctx.delete($0) }
                t.forEach { ctx.delete($0) }
                r.forEach { ctx.delete($0) }
                v.forEach { ctx.delete($0) }
            }
        } catch {
            print("Reset error: \(error)")
        }

        // Сброс флагов
        homeCurrency = "USD"
        monthlyLimit = 0
        appAppearanceRaw = AppAppearance.system.rawValue
        appLanguage = "en"
        hasSeenOnboarding = false // показать онбординг снова
    }
}
