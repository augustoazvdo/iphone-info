import Foundation

/// Battery power state, mapped from UIKit by the caller. Kept UIKit-free so the rules run in tests.
enum BatteryPowerState: Equatable {
    case unplugged
    case charging
    case full
    case unknown
}

/// Battery rows for the painel. Watts, volts, and current are labeled estimates (AD-005).
struct BatteryEstimate: Equatable {
    static let nominalVolts = 3.87
    static let unavailable = "Indisponível"

    let chargeText: String
    let capacityText: String
    let wattsText: String
    let voltsText: String
    let currentText: String
    /// Same estimate as `currentText`. The battery screen shows it as the current coming in.
    let incomingCurrentText: String
    /// Same estimate as `currentText`. The battery screen shows it as the current in use.
    let usedCurrentText: String

    static func make(
        level: Double?,
        cpuUsage: Double,
        state: BatteryPowerState,
        monitoringEnabled: Bool,
        capacityMilliampHours: Int?
    ) -> BatteryEstimate {
        let chargeText = monitoringEnabled
            ? level.map { "\(Int(($0 * 100).rounded()))%" } ?? "—"
            : "—"
        let capacityText = capacityMilliampHours.map { "\($0) mAh" } ?? unavailable

        let wattsText: String
        let voltsText: String
        let currentText: String
        if monitoringEnabled, capacityMilliampHours != nil, let watts = estimatedWatts(cpuUsage: cpuUsage, state: state) {
            let milliamps = Int((watts / nominalVolts * 1000).rounded())
            wattsText = String(format: "%.1f W estimativa", watts)
            voltsText = String(format: "%.2f V estimativa", nominalVolts)
            currentText = "\(milliamps) mA estimativa"
        } else {
            wattsText = unavailable
            voltsText = unavailable
            currentText = unavailable
        }

        return BatteryEstimate(
            chargeText: chargeText,
            capacityText: capacityText,
            wattsText: wattsText,
            voltsText: voltsText,
            currentText: currentText,
            incomingCurrentText: currentText,
            usedCurrentText: currentText)
    }

    /// Unplugged: `1.2 + 4.0 × cpuUsage`, one decimal. Charging 12.0 W. Full 0.5 W. Unknown: none.
    static func estimatedWatts(cpuUsage: Double, state: BatteryPowerState) -> Double? {
        switch state {
        case .unplugged:
            let clamped = min(max(cpuUsage, 0), 1)
            return ((1.2 + 4.0 * clamped) * 10).rounded() / 10
        case .charging: return 12.0
        case .full: return 0.5
        case .unknown: return nil
        }
    }
}
