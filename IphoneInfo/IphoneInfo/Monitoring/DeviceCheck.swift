import Foundation

/// The result of one hardware check.
enum CheckOutcome: Equatable {
    case pass
    case fail
    case unavailable
}

/// The six hardware checks the device check screen records.
enum DeviceCheck {
    static let keys = ["display", "touch", "camera", "microphone", "speaker", "volume"]

    static func word(for outcome: CheckOutcome) -> String {
        switch outcome {
        case .pass: "Aprovado"
        case .fail: "Reprovado"
        case .unavailable: "Indisponível"
        }
    }
}
