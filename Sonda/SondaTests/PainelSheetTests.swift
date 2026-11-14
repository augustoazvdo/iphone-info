import XCTest
@testable import Sonda

final class PainelSheetTests: XCTestCase {
    private let memory = MemorySnapshot(
        total: 8_000_000_000, free: 1_000, active: 2_000, inactive: 3_000, wired: 4_000, compressed: 5_000)
    private let storage = StorageSnapshot(total: 256_000_000_000, available: 100_000_000_000)

    private func sheet(
        cores: [Double] = [0.1, 0.5],
        battery: BatterySnapshot = BatterySnapshot(level: 0.8, state: .unplugged, lowPowerMode: false),
        capacity: Int? = 4422,
        wifi: String? = "192.168.0.10"
    ) -> PainelSheet {
        PainelSheet.make(
            coreUsage: cores,
            estimatedMHz: 2300,
            memory: memory,
            storage: storage,
            network: NetworkRates(wifiDown: 10, wifiUp: 5, cellularDown: 0, cellularUp: 0),
            sessionDownloaded: 1000,
            sessionUploaded: 500,
            wifiAddress: wifi,
            battery: battery,
            capacityMilliampHours: capacity,
            thermal: .nominal)
    }

    private func labels(_ sheet: PainelSheet, _ title: String) -> [String] {
        sheet.sections.first { $0.title == title }?.rows.map(\.label) ?? []
    }

    private func value(_ sheet: PainelSheet, _ title: String, _ label: String) -> String? {
        sheet.sections.first { $0.title == title }?.rows.first { $0.label == label }?.value
    }

    func testPainelShowsLiveFigures() {
        let painel = sheet()
        XCTAssertEqual(
            painel.sections.map(\.title),
            ["Processador", "Memória", "Rede", "Bateria", "Térmico", "Armazenamento"])
        XCTAssertEqual(painel.cpuPercent, "30%")
        XCTAssertEqual(PainelSheet.frequencyCaption, "frequência estimada")
        XCTAssertEqual(labels(painel, "Memória"), ["Usada", "Total", "Ativa", "Fixa (wired)", "Comprimida", "Inativa", "Livre"])
        XCTAssertEqual(labels(painel, "Rede"), ["Download", "Upload", "Recebido nesta sessão", "Enviado nesta sessão", "IP do Wi-Fi"])
        XCTAssertEqual(value(painel, "Rede", "IP do Wi-Fi"), "192.168.0.10")
        XCTAssertEqual(labels(painel, "Armazenamento"), ["Usado", "Total", "Disponível"])
        XCTAssertEqual(value(painel, "Bateria", "Carga"), "80%")
        XCTAssertEqual(value(painel, "Térmico", "Estado"), "Normal")
    }

    func testCatalogModelShowsCapacityAndEstimate() {
        let capacity = DeviceCatalog.spec(for: "iPhone16,2")?.capacityMilliampHours
        let painel = sheet(capacity: capacity)
        XCTAssertEqual(value(painel, "Bateria", "Capacidade"), "4422 mAh")
        XCTAssertEqual(labels(painel, "Bateria"), ["Carga", "Estado", "Capacidade"])
        XCTAssertEqual(
            painel.batteryDetail.rows.map(\.label),
            ["Tensão", "Potência", "Corrente entrando", "Corrente em uso"])
        for row in painel.batteryDetail.rows {
            XCTAssertTrue(row.value.contains("estimativa"), row.label)
        }
        let incoming = painel.batteryDetail.rows.first { $0.label == "Corrente entrando" }?.value
        let used = painel.batteryDetail.rows.first { $0.label == "Corrente em uso" }?.value
        XCTAssertEqual(incoming, used)
        XCTAssertNotNil(incoming)
    }

    func testCoreTapSelectsAndClears() {
        XCTAssertEqual(CoreSelection.toggle(current: nil, tapped: 2), 2)
        XCTAssertNil(CoreSelection.toggle(current: 2, tapped: 2))
        XCTAssertEqual(CoreSelection.toggle(current: 2, tapped: 1), 1)
    }

    func testPauseAndResumeLabels() {
        XCTAssertEqual(MonitorToggle.title(isRunning: true), "Pausar")
        XCTAssertFalse(MonitorToggle.toggled(true))
        XCTAssertEqual(MonitorToggle.title(isRunning: false), "Retomar")
        XCTAssertTrue(MonitorToggle.toggled(false))
    }

    func testNoCoresShowsZeroAndNoControls() {
        let painel = sheet(cores: [])
        XCTAssertEqual(painel.cpuPercent, "0%")
        XCTAssertTrue(painel.cores.isEmpty)
    }

    func testBackgroundStopsAndActiveStarts() {
        XCTAssertFalse(SampleGate.runs(active: false))
        XCTAssertTrue(SampleGate.runs(active: true))
    }

    func testMonitoringOffShowsDashChargeAndNoWattage() {
        let painel = sheet(battery: BatterySnapshot(level: nil, state: .unknown, lowPowerMode: false))
        XCTAssertEqual(value(painel, "Bateria", "Carga"), "—")
        XCTAssertNil(value(painel, "Bateria", "Potência"))
        let power = painel.batteryDetail.rows.first { $0.label == "Potência" }?.value
        XCTAssertEqual(power, "Indisponível")
        XCTAssertFalse(painel.batteryDetail.rows.contains { $0.value.contains("W estimativa") })
    }
}
