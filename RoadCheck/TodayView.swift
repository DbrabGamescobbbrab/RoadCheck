import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var ctx

    @Query private var trips: [Trip]
    @Query private var roads: [TollRoad]
    @Query private var tariffs: [TollTariff]

    @State private var selectedRoad: TollRoad?
    @State private var selectedVehicleCategory: String = ""
    @State private var quantity: Int = 1
    @State private var lastAddedMessage: String?

    init() {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        _trips = Query(
            filter: #Predicate<Trip> { $0.date >= start && $0.date < end },
            sort: \Trip.date,
            order: .reverse
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker(LocalizedStringKey("today_road"), selection: $selectedRoad) {
                    ForEach(roads) { road in
                        Text(road.name + (road.section.isEmpty ? "" : " · \(road.section)"))
                            .tag(Optional(road))
                    }
                }
                .pickerStyle(.menu)

                TextField(
                    String(localized: "today_vehicle_category"),
                    text: $selectedVehicleCategory,
                    prompt: Text(String(localized: "today_vehicle_category_ph"))
                )
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .categoryKeyboardToolbar(text: $selectedVehicleCategory)

                Stepper(
                    String(format: String(localized: "today_quantity"), "\(quantity)"),
                    value: $quantity, in: 1...20
                )

                Button(action: addQuickEntry) {
                    Text(LocalizedStringKey("today_add_entry"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedRoad == nil)

                if roads.isEmpty {
                    Text(String(localized: "empty_add_road"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if let msg = lastAddedMessage {
                    Text(msg).font(.footnote).foregroundStyle(.secondary)
                }

                Divider()
                TotalsView()
                Spacer()
            }
            .padding()
            .navigationTitle(LocalizedStringKey("today_title")) // Welcome back!
            .onAppear {
                // Prefer last used road from prefs; fallback to first available road
                if let savedId = UserPrefs.readLastRoadId(),
                   let match = roads.first(where: { $0.id == savedId }) {
                    selectedRoad = match
                } else if selectedRoad == nil {
                    selectedRoad = roads.first
                }
                // Prefill last vehicle category if empty
                if selectedVehicleCategory.isEmpty, let lastCat = UserPrefs.readLastVehicleCategory() {
                    selectedVehicleCategory = lastCat
                }
            }
            .onChange(of: selectedRoad) { newValue in
                if let road = newValue { UserPrefs.saveLastRoadId(road.id) }
            }
            .onChange(of: selectedVehicleCategory) { newValue in
                UserPrefs.saveLastVehicleCategory(newValue)
            }
        }
    }

    private func addQuickEntry() {
        guard let road = selectedRoad else { return }

        let todayTrip = trips.first ?? {
            let t = Trip(date: .now, title: String(localized: "tab_today"))
            ctx.insert(t)
            return t
        }()

        let cat = selectedVehicleCategory.trimmingCharacters(in: .whitespaces).uppercased()
        let tariff = tariffs.first { $0.roadId == road.id && $0.vehicleCategory.uppercased() == cat }
        let amount = tariff?.amount ?? 0

        let entry = TollEntry(
            tripId: todayTrip.id,
            roadId: road.id,
            vehicleCategory: cat.isEmpty ? "A" : cat,
            quantity: quantity,
            amount: amount,
            currency: road.currency
        )
        ctx.insert(entry)
        Haptics.success()
        UserPrefs.saveLastRoadId(road.id)
        UserPrefs.saveLastVehicleCategory(cat.isEmpty ? "A" : cat)

        lastAddedMessage = String(
            format: String(localized: "today_added"),
            "\(quantity)", road.name, cat.isEmpty ? "A" : cat
        )
        quantity = 1
    }
}

private struct TotalsView: View {
    @Query private var entries: [TollEntry]
    init() {
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        _entries = Query(filter: #Predicate<TollEntry> { $0.timestamp >= start && $0.timestamp < end })
    }
    var body: some View {
        let total = entries.reduce(Decimal(0)) { $0 + ($1.amount * Decimal($1.quantity)) }
        VStack(alignment: .leading, spacing: 8) {
            Text(LocalizedStringKey("today_total_title")).font(.headline)
            Text(String(format: String(localized: "today_total_note"),
                        NSDecimalNumber(decimal: total).stringValue))
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
