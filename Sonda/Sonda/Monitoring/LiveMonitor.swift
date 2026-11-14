import Foundation
import Observation
import UIKit
import WidgetKit

struct HistoryPoint: Identifiable {
    let id: Int
    let value: Double
}

struct BatterySnapshot {
    let level: Double?
    let state: UIDevice.BatteryState
    let lowPowerMode: Bool
}

@Observable
@MainActor
final class LiveMonitor {
    static let historyLength = 60

    private(set) var coreUsage: [Double] = []
    private(set) var totalUsage: Double = 0
    private(set) var estimatedMHz: Double?
    private(set) var memory: MemorySnapshot?
    private(set) var storage: StorageSnapshot?
    private(set) var network = NetworkRates()
    private(set) var sessionDownloaded: UInt64 = 0
    private(set) var sessionUploaded: UInt64 = 0
    private(set) var session = SessionTraffic()
    private(set) var wifiAddress: String?
    private(set) var battery = BatterySnapshot(level: nil, state: .unknown, lowPowerMode: false)
    private(set) var thermalState = ProcessInfo.ThermalState.nominal

    private(set) var cpuHistory: [HistoryPoint] = []
    private(set) var memoryHistory: [HistoryPoint] = []
    private(set) var downloadHistory: [HistoryPoint] = []
    private(set) var uploadHistory: [HistoryPoint] = []
    private(set) var isRunning = false

    /// Nominal capacity of the running model. Nil when the model is not in the catalog.
    var capacityMilliampHours: Int?

    private let cpu = CPUSampler()
    private let networkSampler = NetworkSampler()
    private var tick = 0
    private var loop: Task<Void, Never>?

    func start() {
        guard loop == nil else { return }
        isRunning = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        loop = Task { [weak self] in
            while !Task.isCancelled {
                await self?.refresh()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    func stop() {
        loop?.cancel()
        loop = nil
        isRunning = false
    }

    private func refresh() async {
        coreUsage = cpu.sample()
        totalUsage = coreUsage.isEmpty ? 0 : coreUsage.reduce(0, +) / Double(coreUsage.count)
        memory = MemorySnapshot.current()
        network = networkSampler.sample()
        sessionDownloaded = networkSampler.sessionReceived
        sessionUploaded = networkSampler.sessionSent
        session = networkSampler.session
        thermalState = ProcessInfo.processInfo.thermalState

        let device = UIDevice.current
        battery = BatterySnapshot(
            level: device.batteryLevel >= 0 ? Double(device.batteryLevel) : nil,
            state: device.batteryState,
            lowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled)

        let estimate = BatteryEstimate.make(
            level: battery.level,
            cpuUsage: totalUsage,
            state: PainelSheet.powerState(battery.state),
            monitoringEnabled: battery.level != nil,
            capacityMilliampHours: capacityMilliampHours)
        WidgetSnapshot.make(cpuUsage: totalUsage, batteryLevel: battery.level, wattsText: estimate.wattsText).save()
        if tick % 60 == 0 {
            WidgetCenter.shared.reloadAllTimelines()
        }

        if tick % 10 == 0 {
            storage = StorageSnapshot.current()
            wifiAddress = NetworkSampler.ipv4Address(interfacePrefix: "en0")
        }

        let mhz = await Task.detached(priority: .userInitiated) { sonda_estimate_core_mhz() }.value
        estimatedMHz = mhz > 0 ? mhz : nil

        append(totalUsage, to: &cpuHistory)
        append(memory?.usedFraction ?? 0, to: &memoryHistory)
        append(network.down, to: &downloadHistory)
        append(network.up, to: &uploadHistory)
        tick += 1
    }

    private func append(_ value: Double, to history: inout [HistoryPoint]) {
        history.append(HistoryPoint(id: tick, value: value))
        if history.count > Self.historyLength {
            history.removeFirst(history.count - Self.historyLength)
        }
    }
}
