import XCTest
@testable import IphoneInfo

final class SpeedTestTests: XCTestCase {
    func testFailedSpeedTestIsNotZero() {
        XCTAssertEqual(SpeedTest.rateText(bytesPerSecond: nil), "Teste falhou")
        XCTAssertNil(SpeedTest.bytesPerSecond(bytes: 1000, seconds: 0))
    }

    func testBytesPerSecondFromTimedTransfer() {
        XCTAssertEqual(SpeedTest.bytesPerSecond(bytes: 1000, seconds: 2), 500)
    }
}
