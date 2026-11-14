import Foundation
import UIKit

/// One logical core in the painel grid.
struct CoreRow: Equatable {
    let index: Int
    let usage: Double
    let percentText: String
}

/// The painel's figures, built from one live sample. Views render this and do not recompute it.
struct PainelSheet: Equatable {
    static let frequencyCaption = "frequência estimada"

    let cpuPercent: String
    let frequencyText: String
    let cores: [CoreRow]
    let sections: [SheetSection]
    /// Voltage, wattage, and the two currents. The painel card does not show these rows.
    let batteryDetail: SheetSection

    static func make(
        coreUsage: [Double],
        estimatedMHz: Double?,
        memory: MemorySnapshot?,
        storage: StorageSnapshot?,
        network: NetworkRates,
        sessionDownloaded: UInt64,
        sessionUploaded: UInt64,
        wifiAddress: String?,
        battery: BatterySnapshot,
        capacityMilliampHours: Int?,
        thermal: ProcessInfo.ThermalState
    ) -> PainelSheet {
        let total = coreUsage.isEmpty ? 0 : coreUsage.reduce(0, +) / Double(coreUsage.count)
        let estimate = BatteryEstimate.make(
            level: battery.level,
            cpuUsage: total,
            state: powerState(battery.state),
            monitoringEnabled: battery.level != nil,
            capacityMilliampHours: capacityMilliampHours)

        let processor = SheetSection(title: "Processador", rows: [
            SheetRow(label: "Uso total", value: percentText(total)),
            SheetRow(label: "Frequência", value: estimatedMHz.map(Format.megahertz) ?? "—"),
        ])

        let memoryRows: [SheetRow] = memory.map { memory in
            [
                SheetRow(label: "Usada", value: Format.bytes(memory.used)),
                SheetRow(label: "Total", value: Format.bytes(memory.total)),
                SheetRow(label: "Ativa", value: Format.bytes(memory.active)),
                SheetRow(label: "Fixa (wired)", value: Format.bytes(memory.wired)),
                SheetRow(label: "Comprimida", value: Format.bytes(memory.compressed)),
                SheetRow(label: "Inativa", value: Format.bytes(memory.inactive)),
                SheetRow(label: "Livre", value: Format.bytes(memory.free)),
            ]
        } ?? [SheetRow(label: "Memória", value: "Indisponível")]

        let networkSection = SheetSection(title: "Rede", rows: [
            SheetRow(label: "Download", value: Format.rate(network.down)),
            SheetRow(label: "Upload", value: Format.rate(network.up)),
            SheetRow(label: "Recebido nesta sessão", value: Format.storage(Int64(sessionDownloaded))),
            SheetRow(label: "Enviado nesta sessão", value: Format.storage(Int64(sessionUploaded))),
            SheetRow(label: "IP do Wi-Fi", value: wifiAddress ?? "Sem conexão"),
        ])

        let batterySection = SheetSection(title: "Bateria", rows: [
            SheetRow(label: "Carga", value: estimate.chargeText),
            SheetRow(label: "Estado", value: Format.battery(battery.state)),
            SheetRow(label: "Capacidade", value: estimate.capacityText),
        ])
        let batteryDetail = SheetSection(title: "Bateria", rows: [
            SheetRow(label: "Tensão", value: estimate.voltsText),
            SheetRow(label: "Potência", value: estimate.wattsText),
            SheetRow(label: "Corrente entrando", value: estimate.incomingCurrentText),
            SheetRow(label: "Corrente em uso", value: estimate.usedCurrentText),
        ])

        let storageRows: [SheetRow] = storage.map { storage in
            [
                SheetRow(label: "Usado", value: Format.storage(storage.used)),
                SheetRow(label: "Total", value: Format.storage(storage.total)),
                SheetRow(label: "Disponível", value: Format.storage(storage.available)),
            ]
        } ?? [SheetRow(label: "Armazenamento", value: "Indisponível")]

        return PainelSheet(
            cpuPercent: percentText(total),
            frequencyText: estimatedMHz.map(Format.megahertz) ?? "—",
            cores: coreUsage.enumerated().map { index, usage in
                CoreRow(index: index, usage: usage, percentText: percentText(usage))
            },
            sections: [
                processor,
                SheetSection(title: "Memória", rows: memoryRows),
                networkSection,
                batterySection,
                SheetSection(title: "Térmico", rows: [
                    SheetRow(label: "Estado", value: Format.thermal(thermal)),
                ]),
                SheetSection(title: "Armazenamento", rows: storageRows),
            ],
            batteryDetail: batteryDetail)
    }

    static func powerState(_ state: UIDevice.BatteryState) -> BatteryPowerState {
        switch state {
        case .unplugged: .unplugged
        case .charging: .charging
        case .full: .full
        default: .unknown
        }
    }

    static func percentText(_ fraction: Double) -> String {
        Percent.text(fraction)
    }
}

/// Core grid selection: tapping the selected core clears it.
enum CoreSelection {
    static func toggle(current: Int?, tapped: Int) -> Int? {
        current == tapped ? nil : tapped
    }
}

/// Pause and resume labels for the toolbar button.
enum MonitorToggle {
    static func title(isRunning: Bool) -> String {
        isRunning ? "Pausar" : "Retomar"
    }

    static func toggled(_ isRunning: Bool) -> Bool {
        !isRunning
    }
}

/// The sample loop runs only while the app is active.
enum SampleGate {
    static func runs(active: Bool) -> Bool {
        active
    }
}
