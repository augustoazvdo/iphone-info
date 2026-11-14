import XCTest
@testable import IphoneInfo

final class CompassReadingTests: XCTestCase {
    func testCompassDeniedSaysLocalizacaoDesligada() {
        XCTAssertEqual(CompassReading.text(authorized: false, headingDegrees: 90), "Localização desligada")
        XCTAssertEqual(CompassReading.text(authorized: true, headingDegrees: 90), "90°")
    }
}
