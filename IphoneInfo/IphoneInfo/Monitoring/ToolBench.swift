import Foundation

/// Pure calculations behind the tools screen.
enum ToolBench {
    static let names = ["Decibel", "Régua", "Tom", "Regex"]

    static func regexMatchCount(pattern: String, text: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        return regex.numberOfMatches(in: text, range: NSRange(text.startIndex..., in: text))
    }

    /// Relative level from an averaged recorder power in dBFS. Zero is the quietest the app reports.
    static func decibelText(averagePower: Float) -> String {
        "\(Int(max(0, 90 + Double(averagePower)).rounded())) dB relativo"
    }
}
