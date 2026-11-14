import XCTest
@testable import Sonda

final class MonetizationTests: XCTestCase {
    func testBannerRegionIsVisible() {
        XCTAssertTrue(BannerPresentation.make(loadFailed: false).regionVisible)
        XCTAssertTrue(BannerPresentation.make(loadFailed: true).regionVisible)
    }

    func testBannerFailureSaysAnuncioIndisponivel() {
        XCTAssertEqual(BannerPresentation.make(loadFailed: true).message, "Anúncio indisponível")
        XCTAssertNil(BannerPresentation.make(loadFailed: false).message)
    }

    func testNoPurchaseControls() {
        XCTAssertTrue(Monetization.productIdentifiers.isEmpty)
        XCTAssertTrue(Monetization.purchaseControls(products: Monetization.productIdentifiers).isEmpty)
    }
}
