import SwiftUI

private struct CoreGlassButton: View {
    let index: Int
    let usage: Double
    let percentText: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let button = Button(action: action) {
            VStack(spacing: 6) {
                Text("N\(index + 1)")
                    .font(.caption.weight(.semibold))
                Text(percentText)
                    .font(.subheadline.weight(.bold))
                    .monospacedDigit()
                UsageBar(fraction: usage, tint: usage > 0.8 ? .red : .white.opacity(0.9))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
        }
        .tint(usage > 0.8 ? .red : .blue)

        if isSelected {
            button.buttonStyle(.glassProminent)
        } else {
            button.buttonStyle(.glass)
        }
    }
}

struct DashboardView: View {
    let monitor: LiveMonitor
    let system: SystemInfo

    private let columns = [GridItem(.adaptive(minimum: 72), spacing: 10)]
    @State private var selectedCore: Int?
    @State private var bannerLoadFailed = false

    /// Every figure on the painel comes from this sheet. The view adds layout only.
    private var sheet: PainelSheet {
        PainelSheet.make(
            coreUsage: monitor.coreUsage,
            estimatedMHz: monitor.estimatedMHz,
            memory: monitor.memory,
            storage: monitor.storage,
            network: monitor.network,
            sessionDownloaded: monitor.sessionDownloaded,
            sessionUploaded: monitor.sessionUploaded,
            wifiAddress: monitor.wifiAddress,
            battery: monitor.battery,
            capacityMilliampHours: system.spec?.capacityMilliampHours,
            thermal: monitor.thermalState)
    }

    var body: some View {
        ScrollView {
            GlassEffectContainer(spacing: 16) {
                VStack(spacing: 16) {
                    cpuCard
                    memoryCard
                    networkCard
                    NavigationLink {
                        BatteryDetailView(section: sheet.batteryDetail)
                    } label: {
                        batteryCard
                    }
                    .buttonStyle(.plain)
                    thermalCard
                    storageCard
                    bannerCard
                }
            }
            .padding()
        }
        .background { GlassBackdrop() }
        .navigationTitle(system.displayName)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if monitor.isRunning { monitor.stop() } else { monitor.start() }
                } label: {
                    Label(MonitorToggle.title(isRunning: monitor.isRunning),
                          systemImage: monitor.isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.glass)
                .tint(.blue)
            }
        }
    }

    private func value(_ section: String, _ label: String) -> String {
        sheet.sections.first { $0.title == section }?.rows.first { $0.label == label }?.value ?? "—"
    }

    private func rows(_ section: String, excluding excluded: Set<String> = []) -> some View {
        let visible = sheet.sections.first { $0.title == section }?.rows.filter { !excluded.contains($0.label) } ?? []
        return ForEach(visible, id: \.label) { row in
            ValueRow(label: row.label, value: row.value)
        }
    }

    private var cpuCard: some View {
        MetricCard(title: "Processador", systemImage: "cpu") {
            HStack(alignment: .firstTextBaseline) {
                Text(sheet.cpuPercent)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Spacer()
                VStack(alignment: .trailing) {
                    Text(sheet.frequencyText)
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                    Text(PainelSheet.frequencyCaption).font(.caption).foregroundStyle(.secondary)
                }
            }
            HistoryChart(points: monitor.cpuHistory, maxValue: 1)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(sheet.cores, id: \.index) { core in
                    CoreGlassButton(
                        index: core.index,
                        usage: core.usage,
                        percentText: core.percentText,
                        isSelected: selectedCore == core.index
                    ) {
                        selectedCore = CoreSelection.toggle(current: selectedCore, tapped: core.index)
                    }
                }
            }
        }
    }

    private var memoryCard: some View {
        MetricCard(title: "Memória", systemImage: "memorychip", tint: .purple) {
            if let memory = monitor.memory {
                UsageBar(fraction: memory.usedFraction, tint: .purple)
                rows("Memória")
            } else {
                Text("Indisponível").foregroundStyle(.secondary)
            }
        }
    }

    private var networkCard: some View {
        MetricCard(title: "Rede", systemImage: "arrow.up.arrow.down", tint: .teal) {
            HStack {
                rateColumn(title: "Download", value: value("Rede", "Download"), symbol: "arrow.down", tint: .teal)
                Spacer()
                rateColumn(title: "Upload", value: value("Rede", "Upload"), symbol: "arrow.up", tint: .orange)
            }
            HistoryChart(points: monitor.downloadHistory, secondary: monitor.uploadHistory, tint: .teal)
            rows("Rede", excluding: ["Download", "Upload"])
        }
    }

    private func rateColumn(title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(title, systemImage: symbol).font(.caption).foregroundStyle(tint)
            Text(value).font(.title3.weight(.semibold)).monospacedDigit()
        }
    }

    private var batteryCard: some View {
        MetricCard(title: "Bateria", systemImage: "battery.75percent", tint: .green) {
            Text(value("Bateria", "Carga"))
                .font(.title2.weight(.bold))
                .monospacedDigit()
            UsageBar(fraction: monitor.battery.level ?? 0, tint: .green)
            rows("Bateria", excluding: ["Carga"])
            if monitor.battery.lowPowerMode {
                Text("Modo Pouca Energia").font(.caption).foregroundStyle(.yellow)
            }
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 18)
                .padding(.trailing, 18)
        }
    }

    private var thermalCard: some View {
        MetricCard(title: "Térmico", systemImage: "thermometer.medium", tint: thermalTint) {
            Text(value("Térmico", "Estado"))
                .font(.title2.weight(.bold))
            Text("estado reportado pelo iOS").font(.caption).foregroundStyle(.secondary)
        }
    }

    private var thermalTint: Color {
        switch monitor.thermalState {
        case .nominal: .green
        case .fair: .yellow
        case .serious: .orange
        default: .red
        }
    }

    private var storageCard: some View {
        MetricCard(title: "Armazenamento", systemImage: "internaldrive", tint: .indigo) {
            if let storage = monitor.storage {
                HStack(alignment: .firstTextBaseline) {
                    Text(value("Armazenamento", "Usado")).font(.title2.weight(.bold)).monospacedDigit()
                    Text("de \(value("Armazenamento", "Total"))").foregroundStyle(.secondary)
                }
                UsageBar(fraction: storage.usedFraction, tint: .indigo)
                rows("Armazenamento", excluding: ["Usado", "Total"])
            } else {
                Text("Indisponível").foregroundStyle(.secondary)
            }
        }
    }

    private var bannerCard: some View {
        let presentation = BannerPresentation.make(loadFailed: bannerLoadFailed)
        return MetricCard(title: "Anúncio", systemImage: "megaphone", tint: .gray) {
            if let message = presentation.message {
                Text(message).font(.caption).foregroundStyle(.secondary)
            } else {
                AdBannerView(loadFailed: $bannerLoadFailed)
                    .frame(width: 320, height: 50)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
