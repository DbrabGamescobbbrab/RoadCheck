



import Foundation

/// A tiny preferences helper for values we want to access outside of SwiftUI Views.
/// Uses `UserDefaults.standard` under the hood so it works from any layer.
///
/// Currently stores:
///  - last used TollRoad id (for auto-select in TodayView)
///  - last used vehicle category (optional convenience)
enum UserPrefs {
    enum Keys {
        static let lastRoadId = "lastRoadId"
        static let lastVehicleCategory = "lastVehicleCategory"
    }

    /// Persist the last-used TollRoad identifier. Pass `nil` to clear.
    static func saveLastRoadId(_ id: UUID?) {
        let defaults = UserDefaults.standard
        if let id {
            defaults.set(id.uuidString, forKey: Keys.lastRoadId)
        } else {
            defaults.removeObject(forKey: Keys.lastRoadId)
        }
    }

    /// Read the last-used TollRoad identifier, if present.
    static func readLastRoadId() -> UUID? {
        let defaults = UserDefaults.standard
        guard let raw = defaults.string(forKey: Keys.lastRoadId) else { return nil }
        return UUID(uuidString: raw)
    }

    /// Persist the last-used vehicle category (e.g. "A", "B", "C"). Pass `nil`/empty to clear.
    static func saveLastVehicleCategory(_ category: String?) {
        let defaults = UserDefaults.standard
        let normalized = category?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if let normalized, !normalized.isEmpty {
            defaults.set(normalized, forKey: Keys.lastVehicleCategory)
        } else {
            defaults.removeObject(forKey: Keys.lastVehicleCategory)
        }
    }

    /// Read the last-used vehicle category, if any.
    static func readLastVehicleCategory() -> String? {
        let defaults = UserDefaults.standard
        return defaults.string(forKey: Keys.lastVehicleCategory)
    }

    /// Remove all keys managed by UserPrefs.
    static func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: Keys.lastRoadId)
        defaults.removeObject(forKey: Keys.lastVehicleCategory)
    }
}
