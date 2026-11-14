import Foundation

/// Whole-number percent text. Shared with the widget target, so it depends on nothing else.
enum Percent {
    static func text(_ fraction: Double) -> String {
        "\(Int((min(max(fraction, 0), 1) * 100).rounded()))%"
    }
}
