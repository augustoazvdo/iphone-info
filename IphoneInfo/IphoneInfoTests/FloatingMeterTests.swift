import XCTest
@testable import IphoneInfo

final class FloatingMeterTests: XCTestCase {
    func testFloatingMeterShowsCpuAndBattery() {
        let lines = FloatingMeter.lines(cpuUsage: 0.3, batteryLevel: 0.8)
        XCTAssertEqual(lines.cpu, "CPU 30%")
        XCTAssertEqual(lines.battery, "Bateria 80%")
    }
}
