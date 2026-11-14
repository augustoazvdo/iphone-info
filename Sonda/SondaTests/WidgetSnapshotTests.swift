import XCTest
@testable import Sonda

final class WidgetSnapshotTests: XCTestCase {
    func testWidgetShowsCpuBatteryAndWatts() {
        let snapshot = WidgetSnapshot.make(cpuUsage: 0.3, batteryLevel: 0.8, wattsText: "2.2 W estimativa")
        XCTAssertEqual(snapshot.cpuPercent, "30%")
        XCTAssertEqual(snapshot.batteryPercent, "80%")
        XCTAssertTrue(snapshot.wattsText.contains("estimativa"))
    }
}
