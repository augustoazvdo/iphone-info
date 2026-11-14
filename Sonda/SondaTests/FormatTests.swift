import XCTest
@testable import Sonda

final class FormatTests: XCTestCase {
    func testZeroBytesStayNumeric() {
        for text in [Format.bytes(0), Format.storage(0), Format.rate(0)] {
            XCTAssertTrue(text.contains("0"), text)
            XCTAssertFalse(text.localizedCaseInsensitiveContains("zero"), text)
        }
    }
}
