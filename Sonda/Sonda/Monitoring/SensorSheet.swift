import Foundation

/// The sensores screen rows. A missing sensor shows one fixed sentence; the others keep their values.
enum SensorSheet {
    static let absentSentence = "Indisponível neste aparelho"
    static let waitingSentence = "Aguardando dados…"

    static func make(
        hasDeviceMotion: Bool,
        hasMagnetometer: Bool,
        hasBarometer: Bool,
        acceleration: Vector3?,
        rotationRate: Vector3?,
        magneticField: Vector3?,
        pitch: Double,
        roll: Double,
        yaw: Double,
        pressureKPa: Double?,
        relativeAltitude: Double?
    ) -> [SheetSection] {
        [
            SheetSection(title: "Acelerômetro (g)", rows: hasDeviceMotion
                ? vectorRows(acceleration, withMagnitude: true)
                : absent),
            SheetSection(title: "Giroscópio (rad/s)", rows: hasDeviceMotion
                ? vectorRows(rotationRate, withMagnitude: true)
                : absent),
            SheetSection(title: "Orientação", rows: hasDeviceMotion
                ? [
                    SheetRow(label: "Inclinação (pitch)", value: degrees(pitch)),
                    SheetRow(label: "Rolagem (roll)", value: degrees(roll)),
                    SheetRow(label: "Guinada (yaw)", value: degrees(yaw)),
                ]
                : absent),
            SheetSection(title: "Magnetômetro (µT)", rows: hasMagnetometer
                ? vectorRows(magneticField, withMagnitude: true)
                : absent),
            SheetSection(title: "Barômetro", rows: hasBarometer
                ? [
                    SheetRow(label: "Pressão", value: pressureKPa.map { String(format: "%.2f kPa", $0) } ?? waitingSentence),
                    SheetRow(label: "Altitude relativa", value: relativeAltitude.map { String(format: "%.2f m", $0) } ?? waitingSentence),
                ]
                : absent),
        ]
    }

    private static var absent: [SheetRow] {
        [SheetRow(label: "Sensor", value: absentSentence)]
    }

    private static func vectorRows(_ vector: Vector3?, withMagnitude: Bool) -> [SheetRow] {
        guard let vector else { return [SheetRow(label: "Dados", value: waitingSentence)] }
        var rows = [
            SheetRow(label: "X", value: String(format: "%+.3f", vector.x)),
            SheetRow(label: "Y", value: String(format: "%+.3f", vector.y)),
            SheetRow(label: "Z", value: String(format: "%+.3f", vector.z)),
        ]
        if withMagnitude {
            rows.append(SheetRow(label: "Magnitude", value: String(format: "%.3f", vector.magnitude)))
        }
        return rows
    }

    private static func degrees(_ radians: Double) -> String {
        String(format: "%+.1f°", radians * 180 / .pi)
    }
}
