import SwiftUI
import SwiftData

struct TripsView: View {
    @Environment(\.modelContext) private var ctx
    @Query(sort: \Trip.date, order: .reverse) private var trips: [Trip]
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(trips) { t in
                        NavigationLink {
                            TripDetailView(trip: t)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(t.title.isEmpty ? formatted(t.date) : t.title)
                                    .font(.headline)
                                if let tag = t.projectTag, !tag.isEmpty {
                                    Text(tag).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { idx in
                        idx.map { trips[$0] }.forEach(ctx.delete)
                    }
                }
                if trips.isEmpty {
                    EmptyOverlay(textKey: "empty_trips")
                        .allowsHitTesting(false)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showNew = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showNew) { NewTripSheet() }
            .navigationTitle(LocalizedStringKey("trips_title"))
        }
    }

    private func formatted(_ d: Date) -> String {
        let df = DateFormatter(); df.dateStyle = .medium
        return df.string(from: d)
    }
}

struct TripDetailView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var trip: Trip
    @Query private var roads: [TollRoad]
    @Query private var tariffs: [TollTariff]
    @State private var selectedRoad: TollRoad?
    @State private var category: String = "A"
    @State private var qty: Int = 1
    @State private var note: String = ""

    init(trip: Trip) {
        self.trip = trip
        _roads = Query()
        _tariffs = Query()
    }

    var body: some View {
        List {
            Section(LocalizedStringKey("trip_add_section")) {
                Picker(LocalizedStringKey("trip_road"), selection: $selectedRoad) {
                    ForEach(roads) { Text($0.name).tag(Optional($0)) }
                }
                .pickerStyle(.menu)

                TextField(LocalizedStringKey("trip_category"), text: $category)
                    .textInputAutocapitalization(.characters)
                    .categoryKeyboardToolbar(text: $category)
                Stepper(String(format: String(localized: "trip_qty"), "\(qty)"), value: $qty, in: 1...50)
                TextField(LocalizedStringKey("trip_note"), text: $note)

                Button(LocalizedStringKey("trip_add")) { addEntry() }
                    .disabled(selectedRoad == nil)
            }

            Section(LocalizedStringKey("trip_entries")) {
                ForEach(entriesForTrip()) { e in
                    VStack(alignment: .leading) {
                        Text(roadName(e.roadId))
                        Text("\(e.quantity) × \(e.vehicleCategory) · \(e.amount) \(e.currency)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let n = e.note, !n.isEmpty {
                            Text(n).font(.caption2)
                        }
                    }
                }
                .onDelete { idx in
                    idx.map { entriesForTrip()[$0] }.forEach(ctx.delete)
                }
            }
        }
        .navigationTitle(trip.title.isEmpty ? String(localized: "trip_detail_title") : trip.title)
    }

    private func addEntry() {
        guard let road = selectedRoad else { return }
        let tariff = tariffs.first { $0.roadId == road.id && $0.vehicleCategory.uppercased() == category.uppercased() }
        let amount = tariff?.amount ?? 0
        let e = TollEntry(tripId: trip.id, roadId: road.id, vehicleCategory: category.uppercased(), quantity: qty, amount: amount, currency: road.currency, note: note.isEmpty ? nil : note)
        ctx.insert(e)
        Haptics.success()
        qty = 1; note = ""
    }

    @Query private var allEntries: [TollEntry]
    private func entriesForTrip() -> [TollEntry] {
        allEntries.filter { $0.tripId == trip.id }.sorted(by: { $0.timestamp > $1.timestamp })
    }
    private func roadName(_ id: UUID) -> String { roads.first(where: { $0.id == id })?.name ?? String(localized: "road_title") }
}

struct NewTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @State private var title = ""
    @State private var date = Date()
    @State private var tag = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "veh_name"), text: $title)
                DatePicker(String(localized: "trip_date"), selection: $date, displayedComponents: .date)
                TextField(String(localized: "trip_tag"), text: $tag)
            }
            .navigationTitle(LocalizedStringKey("trip_new_title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(LocalizedStringKey("trip_cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("trip_create")) {
                        let t = Trip(date: date, title: title, projectTag: tag.isEmpty ? nil : tag)
                        ctx.insert(t); dismiss()
                    }
                }
            }
        }
    }
}
