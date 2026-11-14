import Foundation

/// Scores from this app's own loops. They are not comparable to any third-party benchmark.
enum Benchmarks {
    static let scoreLabel = "Pontuação Iphone Info"
    static let allocationFailureText = "Memória insuficiente"
    static let memoryBytes = 64 * 1024 * 1024

    struct CPUScore: Equatable {
        let integer: Int
        let floating: Double
    }

    struct MemoryRates: Equatable {
        let readMBps: Double
        let writeMBps: Double
        let copyMBps: Double
    }

    static func memoryRateText(mbPerSecond: Double?) -> String {
        guard let mbPerSecond else { return allocationFailureText }
        return String(format: "%.0f MB/s", mbPerSecond)
    }

    /// One integer loop and one floating-point loop, scored in millions of operations per second.
    static func measureCPU() -> CPUScore {
        let iterations = 20_000_000

        let integerStart = ContinuousClock.now
        var integerAccumulator: UInt64 = 1
        for index in 0..<iterations {
            integerAccumulator = integerAccumulator &* 6364136223846793005 &+ UInt64(index)
        }
        let integerSeconds = seconds(since: integerStart)

        let floatingStart = ContinuousClock.now
        var floatingAccumulator = 1.0
        for index in 0..<iterations {
            floatingAccumulator = (floatingAccumulator * 1.0000001 + Double(index & 7)).squareRoot()
        }
        let floatingSeconds = seconds(since: floatingStart)

        // Keep both accumulators alive so the loops are not optimized away.
        if integerAccumulator == 0 || floatingAccumulator == 0 { return CPUScore(integer: 0, floating: 0) }
        return CPUScore(
            integer: Int(Double(iterations) / max(integerSeconds, 1e-9) / 1_000_000),
            floating: Double(iterations) / max(floatingSeconds, 1e-9) / 1_000_000)
    }

    /// Read, write, and copy rates over one block. Nil when the block cannot be allocated.
    static func measureMemory() -> MemoryRates? {
        guard let source = malloc(memoryBytes) else { return nil }
        guard let target = malloc(memoryBytes) else {
            free(source)
            return nil
        }
        defer {
            free(source)
            free(target)
        }

        let writeStart = ContinuousClock.now
        memset(source, 1, memoryBytes)
        let writeSeconds = seconds(since: writeStart)

        let readStart = ContinuousClock.now
        var sum: UInt64 = 0
        let words = source.assumingMemoryBound(to: UInt64.self)
        for index in 0..<(memoryBytes / 8) {
            sum &+= words[index]
        }
        let readSeconds = seconds(since: readStart)

        let copyStart = ContinuousClock.now
        memcpy(target, source, memoryBytes)
        let copySeconds = seconds(since: copyStart)

        if sum == 0 { return nil }
        let megabytes = Double(memoryBytes) / 1_048_576
        return MemoryRates(
            readMBps: megabytes / max(readSeconds, 1e-9),
            writeMBps: megabytes / max(writeSeconds, 1e-9),
            copyMBps: megabytes / max(copySeconds, 1e-9))
    }

    private static func seconds(since start: ContinuousClock.Instant) -> Double {
        let duration = ContinuousClock.now - start
        return Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1e18
    }
}
