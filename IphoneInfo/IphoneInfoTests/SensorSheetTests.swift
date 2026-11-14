import XCTest
@testable import IphoneInfo

final class SensorSheetTests: XCTestCase {
    private func make(hasBarometer: Bool) -> [SheetSection] {
        SensorSheet.make(
            hasDeviceMotion: true,
            hasMagnetometer: true,
            hasBarometer: hasBarometer,
            acceleration: Vector3(x: 0.1, y: -0.2, z: 0.98),
            rotationRate: Vector3(x: 0, y: 0, z: 0),
            magneticField: Vector3(x: 20, y: 0, z: -40),
            pitch: 0, roll: 0, yaw: 0,
            pressureKPa: 101.3,
            relativeAltitude: 1.5)
    }

    private func rows(_ sections: [SheetSection], _ title: String) -> [SheetRow] {
        sections.first { $0.title == title }?.rows ?? []
    }

    func testSensorsShowAxesWhenPresent() {
        let sections = make(hasBarometer: true)
        XCTAssertEqual(rows(sections, "Acelerômetro (g)").map(\.label), ["X", "Y", "Z", "Magnitude"])
        XCTAssertEqual(rows(sections, "Magnetômetro (µT)").map(\.label), ["X", "Y", "Z", "Magnitude"])
        XCTAssertEqual(rows(sections, "Orientação").map(\.label), ["Inclinação (pitch)", "Rolagem (roll)", "Guinada (yaw)"])
        XCTAssertEqual(rows(sections, "Barômetro").map(\.label), ["Pressão", "Altitude relativa"])
        XCTAssertEqual(rows(sections, "Barômetro")[0].value, "101.30 kPa")
        XCTAssertEqual(rows(sections, "Barômetro")[1].value, "1.50 m")
    }

    func testAbsentSensorSaysIndisponivel() {
        let sections = make(hasBarometer: false)
        XCTAssertEqual(rows(sections, "Barômetro").map(\.value), ["Indisponível neste aparelho"])
        XCTAssertEqual(rows(sections, "Acelerômetro (g)").first?.label, "X")
    }
}
