import Foundation

/// The two lines the floating meter shows inside its Picture in Picture window.
enum FloatingMeter {
    static func lines(cpuUsage: Double, batteryLevel: Double?) -> (cpu: String, battery: String) {
        (
            cpu: "CPU \(PainelSheet.percentText(cpuUsage))",
            battery: "Bateria \(batteryLevel.map(PainelSheet.percentText) ?? "—")"
        )
    }
}
