import Foundation
import SwiftData

func decString(_ d: Decimal) -> String {
    NSDecimalNumber(decimal: d).stringValue
}

@Model
final class Vehicle {
    @Attribute(.unique) var id: UUID
    var name: String
    var plate: String
    var category: String
    var isDefault: Bool

    init(name: String, plate: String, category: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.plate = plate
        self.category = category
        self.isDefault = isDefault
    }
}

@Model
final class TollRoad {
    @Attribute(.unique) var id: UUID
    var name: String
    var section: String
    var direction: String
    var currency: String
    var notes: String?

    init(name: String, section: String = "", direction: String = "", currency: String = "USD", notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.section = section
        self.direction = direction
        self.currency = currency
        self.notes = notes
    }
}

@Model
final class TollTariff {
    @Attribute(.unique) var id: UUID
    var roadId: UUID
    var vehicleCategory: String
    var amount: Decimal

    init(roadId: UUID, vehicleCategory: String, amount: Decimal) {
        self.id = UUID()
        self.roadId = roadId
        self.vehicleCategory = vehicleCategory
        self.amount = amount
    }
}

@Model
final class Trip {
    @Attribute(.unique) var id: UUID
    var date: Date
    var title: String
    var notes: String?
    var projectTag: String?
    var vehicleId: UUID?

    init(date: Date = .now, title: String = "", notes: String? = nil, projectTag: String? = nil, vehicleId: UUID? = nil) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.notes = notes
        self.projectTag = projectTag
        self.vehicleId = vehicleId
    }
}

@Model
final class TollEntry {
    @Attribute(.unique) var id: UUID
    var tripId: UUID
    var roadId: UUID
    var vehicleCategory: String
    var quantity: Int
    var amount: Decimal       // сумма за один проезд
    var currency: String
    var timestamp: Date
    var note: String?

    init(tripId: UUID, roadId: UUID, vehicleCategory: String, quantity: Int = 1, amount: Decimal, currency: String, timestamp: Date = .now, note: String? = nil) {
        self.id = UUID()
        self.tripId = tripId
        self.roadId = roadId
        self.vehicleCategory = vehicleCategory
        self.quantity = max(1, quantity)
        self.amount = amount
        self.currency = currency
        self.timestamp = timestamp
        self.note = note
    }
}
