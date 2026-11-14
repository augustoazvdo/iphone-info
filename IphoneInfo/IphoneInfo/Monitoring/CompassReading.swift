import Foundation

/// The compass text. Denied location permission replaces the heading with one sentence.
enum CompassReading {
    static let deniedText = "Localização desligada"

    static func text(authorized: Bool, headingDegrees: Double?) -> String {
        guard authorized else { return deniedText }
        guard let headingDegrees else { return "Aguardando…" }
        return "\(Int(headingDegrees.rounded()))°"
    }
}
