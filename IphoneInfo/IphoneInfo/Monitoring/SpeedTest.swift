import Foundation

/// The measured numbers of one speed run.
struct SpeedResult: Equatable {
    let pingMilliseconds: Double
    let downloadBytesPerSecond: Double
    let uploadBytesPerSecond: Double
}

enum SpeedTest {
    static let failureText = "Teste falhou"
    static let downloadURL = URL(string: "https://speed.cloudflare.com/__down?bytes=10000000")!
    static let uploadURL = URL(string: "https://speed.cloudflare.com/__up")!
    static let uploadBytes = 2_000_000

    /// Bytes per second over a timed transfer. A zero or negative duration has no rate.
    static func bytesPerSecond(bytes: Int, seconds: Double) -> Double? {
        seconds > 0 ? Double(bytes) / seconds : nil
    }

    /// A failed run shows the failure sentence, never a zero rate.
    static func rateText(bytesPerSecond: Double?) -> String {
        guard let bytesPerSecond else { return failureText }
        return Format.rate(bytesPerSecond)
    }

    /// Runs one ping, one download, and one upload. Throws when any request fails.
    static func run() async throws -> SpeedResult {
        let pingStart = ContinuousClock.now
        var ping = URLRequest(url: downloadURL)
        ping.httpMethod = "HEAD"
        _ = try await URLSession.shared.data(for: ping)
        let pingMilliseconds = Double((ContinuousClock.now - pingStart).components.attoseconds) / 1e15

        let downloadStart = ContinuousClock.now
        let (data, _) = try await URLSession.shared.data(from: downloadURL)
        let downloadSeconds = seconds(since: downloadStart)
        guard let down = bytesPerSecond(bytes: data.count, seconds: downloadSeconds) else { throw URLError(.unknown) }

        var upload = URLRequest(url: uploadURL)
        upload.httpMethod = "POST"
        let payload = Data(count: uploadBytes)
        let uploadStart = ContinuousClock.now
        _ = try await URLSession.shared.upload(for: upload, from: payload)
        let uploadSeconds = seconds(since: uploadStart)
        guard let up = bytesPerSecond(bytes: uploadBytes, seconds: uploadSeconds) else { throw URLError(.unknown) }

        return SpeedResult(pingMilliseconds: pingMilliseconds, downloadBytesPerSecond: down, uploadBytesPerSecond: up)
    }

    private static func seconds(since start: ContinuousClock.Instant) -> Double {
        let duration = ContinuousClock.now - start
        return Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
    }
}
