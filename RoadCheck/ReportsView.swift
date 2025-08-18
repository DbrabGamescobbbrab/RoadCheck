import SwiftUI
import SwiftData

struct ReportsView: View {
    @Query private var entries: [TollEntry]
    @Query private var roads: [TollRoad]

    var body: some View {
        let total = entries.reduce(Decimal(0)) { $0 + ($1.amount * Decimal($1.quantity)) }
        NavigationStack {
            List {
                Section(LocalizedStringKey("reports_title")) {
                    Text(String(format: String(localized: "reports_total"), decString(total)))
                    Text(String(format: String(localized: "reports_count"), "\(entries.count)"))
                }
                Section(LocalizedStringKey("reports_by_road")) {
                    ForEach(groupByRoad(), id: \.0) { (roadId, sum, count) in
                        Text("\(roadName(roadId)): \(NSDecimalNumber(decimal: sum)) · \(count)")
                    }
                }
            }
            .navigationTitle(LocalizedStringKey("reports_title"))
        }
    }

    private func groupByRoad() -> [(UUID, Decimal, Int)] {
        var dict: [UUID: (sum: Decimal, count: Int)] = [:]
        for e in entries {
            let s = (dict[e.roadId]?.sum ?? 0) + e.amount * Decimal(e.quantity)
            let c = (dict[e.roadId]?.count ?? 0) + e.quantity
            dict[e.roadId] = (s, c)
        }
        return dict.map { ($0.key, $0.value.sum, $0.value.count) }.sorted { $0.1 > $1.1 }
    }

    private func roadName(_ id: UUID) -> String {
        roads.first(where: { $0.id == id })?.name ?? String(localized: "road_title")
    }
}
