import XCTest
@testable import IphoneInfo

final class DeviceSheetTests: XCTestCase {
    private func system(identifier: String, gpu: GPUInfo?) -> SystemInfo {
        SystemInfo(
            modelIdentifier: identifier,
            spec: DeviceCatalog.spec(for: identifier),
            deviceName: "iPhone de teste",
            systemName: "iOS",
            systemVersion: "27.0",
            buildNumber: "24A100",
            kernelVersion: "25.0.0",
            bootDate: Date().addingTimeInterval(-3600),
            cores: CoreLayout(performance: 2, efficiency: 4, logical: 6),
            l1DataCache: 65_536,
            l2Cache: 16_777_216,
            physicalMemory: 8_000_000_000,
            gpu: gpu,
            screenPixels: CGSize(width: 1290, height: 2796),
            screenScale: 3,
            maxFramesPerSecond: 120)
    }

    private let gpu = GPUInfo(name: "Apple GPU", family: "Apple 9", supportsRayTracing: true, recommendedWorkingSet: 5_000_000_000)

    private func labels(_ sections: [SheetSection], _ title: String) -> [String] {
        sections.first { $0.title == title }?.rows.map(\.label) ?? []
    }

    private func value(_ sections: [SheetSection], _ title: String, _ label: String) -> String? {
        sections.first { $0.title == title }?.rows.first { $0.label == label }?.value
    }

    func testDeviceSheetListsHardware() {
        let sections = DeviceSheet.make(system: system(identifier: "iPhone16,2", gpu: gpu))
        XCTAssertEqual(value(sections, "Dispositivo", "Modelo"), "iPhone 15 Pro Max")
        XCTAssertEqual(value(sections, "Dispositivo", "Identificador"), "iPhone16,2")
        XCTAssertEqual(value(sections, "Processador", "Chip"), "Apple A17 Pro")
        XCTAssertEqual(value(sections, "Processador", "Frequência máxima"), "3.78 GHz")
        XCTAssertEqual(value(sections, "Processador", "Núcleos de desempenho"), "2")
        XCTAssertEqual(value(sections, "Processador", "Núcleos de eficiência"), "4")
        XCTAssertNotNil(value(sections, "Processador", "Cache L1 de dados"))
        XCTAssertNotNil(value(sections, "Processador", "Cache L2"))
        XCTAssertEqual(value(sections, "GPU", "Ray tracing"), "Sim")
        XCTAssertEqual(value(sections, "GPU", "Família Metal"), "Apple 9")
        XCTAssertEqual(value(sections, "Tela", "Taxa de atualização máxima"), "120 Hz")
        XCTAssertEqual(value(sections, "Sistema", "Build"), "24A100")
        XCTAssertEqual(value(sections, "Sistema", "Kernel Darwin"), "25.0.0")
        XCTAssertNotNil(value(sections, "Sistema", "Ligado há"))
        XCTAssertNotNil(value(sections, "Memória", "RAM física"))
    }

    func testUnknownChipShowsDesconhecido() {
        let sections = DeviceSheet.make(system: system(identifier: "iPhone99,9", gpu: nil))
        XCTAssertEqual(value(sections, "Processador", "Chip"), "Desconhecido")
        XCTAssertFalse(labels(sections, "Processador").contains("Processo"))
        XCTAssertEqual(value(sections, "GPU", "GPU"), "Metal indisponível")
    }
}
