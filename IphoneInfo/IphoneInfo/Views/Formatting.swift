import Foundation
import UIKit

enum Format {
    static func bytes<T: BinaryInteger>(_ value: T) -> String {
        count(Int64(value), style: .memory)
    }

    static func storage(_ value: Int64) -> String {
        count(value, style: .file)
    }

    static func rate(_ bytesPerSecond: Double) -> String {
        count(Int64(bytesPerSecond), style: .file) + "/s"
    }

    /// Numeric zero. The shared formatter otherwise spells 0 as "Zero KB" in some locales.
    private static func count(_ value: Int64, style: ByteCountFormatter.CountStyle) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = style
        formatter.allowsNonnumericFormatting = false
        return formatter.string(fromByteCount: value)
    }

    static func percent(_ fraction: Double) -> String {
        fraction.formatted(.percent.precision(.fractionLength(0)))
    }

    static func megahertz(_ mhz: Double) -> String {
        mhz >= 1000
            ? String(format: "%.2f GHz", mhz / 1000)
            : String(format: "%.0f MHz", mhz)
    }

    static func duration(since date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: date, to: .now) ?? "—"
    }

    static func thermal(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal: "Normal"
        case .fair: "Moderado"
        case .serious: "Alto"
        case .critical: "Crítico"
        @unknown default: "Desconhecido"
        }
    }

    static func battery(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: "Carregando"
        case .full: "Completa"
        case .unplugged: "Descarregando"
        case .unknown: "Indisponível"
        @unknown default: "Desconhecido"
        }
    }
}
