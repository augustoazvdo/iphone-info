import XCTest
@testable import Sonda

final class DeviceCheckTests: XCTestCase {
    func testDeviceCheckRecordsPassFailUnavailable() {
        XCTAssertEqual(DeviceCheck.keys, ["display", "touch", "camera", "microphone", "speaker", "volume"])
        XCTAssertEqual(DeviceCheck.word(for: .pass), "Aprovado")
        XCTAssertEqual(DeviceCheck.word(for: .fail), "Reprovado")
        XCTAssertEqual(DeviceCheck.word(for: .unavailable), "Indisponível")
    }
}
