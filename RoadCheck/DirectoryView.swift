import SwiftUI
import SwiftData

struct DirectoryView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(LocalizedStringKey("dir_roads")) { RoadsView() }
                NavigationLink(LocalizedStringKey("dir_vehicles")) { VehiclesView() }
            }
            .navigationTitle(LocalizedStringKey("dir_title"))
        }
    }
}

struct RoadsView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var roads: [TollRoad]
    @Query private var tariffs: [TollTariff]
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(roads) { road in
                        NavigationLink {
                            RoadDetailView(road: road)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(road.name).font(.headline)
                                if !road.section.isEmpty {
                                    Text(road.section).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { idx in
                        idx.map { roads[$0] }.forEach { r in
                            tariffs.filter { $0.roadId == r.id }.forEach(ctx.delete)
                            ctx.delete(r)
                        }
                    }
                }
                if roads.isEmpty {
                    EmptyOverlay(textKey: "empty_roads")
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle(LocalizedStringKey("dir_roads"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showNew = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showNew) { NewRoadSheet() }
        }
    }
}

struct RoadDetailView: View {
    @Environment(\.modelContext) private var ctx
    @Bindable var road: TollRoad
    @Query private var tariffs: [TollTariff]
    @State private var cat = "A"
    @State private var amt = ""

    init(road: TollRoad) {
        self.road = road
        _tariffs = Query()
    }

    var body: some View {
        Form {
            Section(LocalizedStringKey("road_info")) {
                TextField(String(localized: "road_name"), text: $road.name)
                TextField(String(localized: "road_section"), text: $road.section)
                TextField(String(localized: "road_direction"), text: $road.direction)
                TextField(String(localized: "road_currency"), text: $road.currency)
            }
            Section(LocalizedStringKey("road_tariffs")) {
                HStack {
                    TextField(String(localized: "road_cat"), text: $cat).frame(width: 60)
                    TextField(String(localized: "road_amount"), text: $amt).keyboardType(.decimalPad)
                    Spacer()
                    Button(LocalizedStringKey("road_add")) {
                        if let value = Decimal(string: amt) {
                            let t = TollTariff(roadId: road.id, vehicleCategory: cat.uppercased(), amount: value)
                            ctx.insert(t); amt = ""
                        }
                    }
                }
                ForEach(tariffs.filter { $0.roadId == road.id }) { t in
                    HStack {
                        Text(t.vehicleCategory).bold()
                        Spacer()
                        Text("\(NSDecimalNumber(decimal: t.amount)) \(road.currency)")
                    }
                }
                .onDelete { idx in
                    let filtered = tariffs.filter { $0.roadId == road.id }
                    idx.map { filtered[$0] }.forEach(ctx.delete)
                }
            }
        }
        .navigationTitle(LocalizedStringKey("road_title"))
    }
}

struct NewRoadSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @State private var name = ""
    @State private var section = ""
    @State private var currency = "USD"

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "road_name"), text: $name)
                TextField(String(localized: "road_section"), text: $section)
                TextField(String(localized: "road_currency"), text: $currency)
            }
            .navigationTitle(LocalizedStringKey("road_title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(LocalizedStringKey("trip_cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("trip_create")) {
                        ctx.insert(TollRoad(name: name, section: section, currency: currency))
                        dismiss()
                    }
                }
            }
        }
    }
}

struct VehiclesView: View {
    @Environment(\.modelContext) private var ctx
    @Query private var vehicles: [Vehicle]
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    ForEach(vehicles) { v in
                        VStack(alignment: .leading) {
                            Text(v.name).font(.headline)
                            Text("\(v.plate) · \(String(localized: "veh_category")) \(v.category)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { idx in
                        idx.map { vehicles[$0] }.forEach(ctx.delete)
                    }
                }
                if vehicles.isEmpty {
                    EmptyOverlay(textKey: "empty_vehicles")
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle(LocalizedStringKey("dir_vehicles"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showNew = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showNew) { NewVehicleSheet() }
        }
    }
}

struct NewVehicleSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @State private var name = ""
    @State private var plate = ""
    @State private var category = "A"
    @State private var isDefault = false

    var body: some View {
        NavigationStack {
            Form {
                TextField(String(localized: "veh_name"), text: $name)
                TextField(String(localized: "veh_plate"), text: $plate)
                TextField(String(localized: "veh_category"), text: $category)
                Toggle(String(localized: "veh_default"), isOn: $isDefault)
            }
            .navigationTitle(LocalizedStringKey("veh_new"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(LocalizedStringKey("trip_cancel")) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("veh_create")) {
                        ctx.insert(Vehicle(name: name, plate: plate, category: category.uppercased(), isDefault: isDefault))
                        dismiss()
                    }
                }
            }
        }
    }
}
