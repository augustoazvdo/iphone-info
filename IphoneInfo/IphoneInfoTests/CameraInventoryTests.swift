import XCTest
@testable import IphoneInfo

final class CameraInventoryTests: XCTestCase {
    func testEmptyCameraListSaysNenhumaCamera() {
        let rows = CameraInventory.rows(for: [])
        XCTAssertEqual(rows.map(\.value), ["Nenhuma câmera"])
    }

    func testCameraRowsShowPositionAndType() {
        let rows = CameraInventory.rows(for: [CameraEntry(position: "Traseira", deviceType: "Grande-angular")])
        XCTAssertEqual(rows, [SheetRow(label: "Traseira", value: "Grande-angular")])
    }
}
