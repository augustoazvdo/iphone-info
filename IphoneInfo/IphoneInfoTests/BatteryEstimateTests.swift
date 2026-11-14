import XCTest
@testable import IphoneInfo

final class BatteryEstimateTests: XCTestCase {
    func testUnpluggedQuarterIsTwoPointTwoWatts() {
        let estimate = BatteryEstimate.make(
            level: 0.8, cpuUsage: 0.25, state: .unplugged, monitoringEnabled: true, capacityMilliampHours: 4422)
        XCTAssertEqual(estimate.wattsText, "2.2 W estimativa")
    }

    func testChargingIsTwelveWatts() {
        let estimate = BatteryEstimate.make(
            level: 0.5, cpuUsage: 0.9, state: .charging, monitoringEnabled: true, capacityMilliampHours: 4422)
        XCTAssertEqual(estimate.wattsText, "12.0 W estimativa")
        XCTAssertEqual(estimate.currentText, "3101 mA estimativa")
    }

    func testFullIsHalfWatt() {
        let estimate = BatteryEstimate.make(
            level: 1.0, cpuUsage: 0.9, state: .full, monitoringEnabled: true, capacityMilliampHours: 4422)
        XCTAssertEqual(estimate.wattsText, "0.5 W estimativa")
        XCTAssertEqual(estimate.currentText, "129 mA estimativa")
    }

    func testVoltageAndCurrentFromWatts() {
        let estimate = BatteryEstimate.make(
            level: 0.8, cpuUsage: 0.25, state: .unplugged, monitoringEnabled: true, capacityMilliampHours: 4422)
        XCTAssertEqual(estimate.voltsText, "3.87 V estimativa")
        XCTAssertEqual(estimate.currentText, "568 mA estimativa")
        XCTAssertEqual(estimate.incomingCurrentText, estimate.currentText)
        XCTAssertEqual(estimate.usedCurrentText, estimate.currentText)
    }

    func testMonitoringOffSkipsWattFormula() {
        let estimate = BatteryEstimate.make(
            level: 0.8, cpuUsage: 0.25, state: .unplugged, monitoringEnabled: false, capacityMilliampHours: 4422)
        XCTAssertEqual(estimate.chargeText, "—")
        XCTAssertEqual(estimate.wattsText, "Indisponível")
        XCTAssertEqual(estimate.currentText, "Indisponível")
    }

    func testUnknownStateHasNoWattage() {
        let estimate = BatteryEstimate.make(
            level: 0.8, cpuUsage: 0.25, state: .unknown, monitoringEnabled: true, capacityMilliampHours: 4422)
        XCTAssertEqual(estimate.wattsText, "Indisponível")
    }

    func testUnknownModelHasNoWattage() {
        let estimate = BatteryEstimate.make(
            level: 0.8, cpuUsage: 0.25, state: .unplugged, monitoringEnabled: true, capacityMilliampHours: nil)
        XCTAssertEqual(estimate.capacityText, "Indisponível")
        XCTAssertEqual(estimate.wattsText, "Indisponível")
        XCTAssertEqual(estimate.voltsText, "Indisponível")
        XCTAssertEqual(estimate.currentText, "Indisponível")
        XCTAssertEqual(estimate.incomingCurrentText, "Indisponível")
        XCTAssertEqual(estimate.usedCurrentText, "Indisponível")
        XCTAssertFalse(estimate.wattsText.contains("W"))
    }
}
