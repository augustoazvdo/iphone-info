import XCTest
@testable import IphoneInfo

final class DeviceCatalogTests: XCTestCase {
    func testIPhone15ProMaxCapacity() {
        XCTAssertEqual(DeviceCatalog.spec(for: "iPhone16,2")?.capacityMilliampHours, 4422)
    }

    func testCatalogCapacitiesMatchPublishedFigures() {
        let expected: [String: Int] = [
            "iPhone13,1": 2227, "iPhone13,2": 2815, "iPhone13,3": 2815, "iPhone13,4": 3687,
            "iPhone14,4": 2406, "iPhone14,5": 3227, "iPhone14,2": 3095, "iPhone14,3": 4352,
            "iPhone14,6": 2018, "iPhone14,7": 3279, "iPhone14,8": 4325, "iPhone15,2": 3200,
            "iPhone15,3": 4323, "iPhone15,4": 3349, "iPhone15,5": 4383, "iPhone16,1": 3274,
            "iPhone17,3": 3561, "iPhone17,4": 4674, "iPhone17,1": 3582, "iPhone17,2": 4685,
            "iPhone17,5": 4005,
        ]
        for (identifier, mah) in expected {
            XCTAssertEqual(DeviceCatalog.spec(for: identifier)?.capacityMilliampHours, mah, identifier)
        }
    }

    func testUnknownIdentifierHasNoSpec() {
        XCTAssertNil(DeviceCatalog.spec(for: "iPhone99,9"))
    }
}
