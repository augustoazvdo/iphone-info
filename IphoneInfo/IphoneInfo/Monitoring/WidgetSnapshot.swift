import Foundation

/// What the home-screen widget shows. The app writes it into the shared app group after each sample.
struct WidgetSnapshot: Codable, Equatable {
    static let appGroup = "group.com.azvdo.iphoneinfo"
    static let storageKey = "widgetSnapshot"

    let cpuPercent: String
    let batteryPercent: String
    let wattsText: String

    static func make(cpuUsage: Double, batteryLevel: Double?, wattsText: String) -> WidgetSnapshot {
        WidgetSnapshot(
            cpuPercent: Percent.text(cpuUsage),
            batteryPercent: batteryLevel.map(Percent.text) ?? "—",
            wattsText: wattsText)
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults(suiteName: Self.appGroup)?.set(data, forKey: Self.storageKey)
    }

    static func load() -> WidgetSnapshot? {
        guard let data = UserDefaults(suiteName: appGroup)?.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }
}
