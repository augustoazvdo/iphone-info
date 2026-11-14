import XCTest
@testable import IphoneInfo

final class BenchmarksTests: XCTestCase {
    func testBenchmarkScoresAreIphoneInfoNotGeekbench() {
        XCTAssertEqual(Benchmarks.scoreLabel, "Pontuação Iphone Info")
        XCTAssertFalse(Benchmarks.scoreLabel.contains("Geekbench"))
        let score = Benchmarks.measureCPU()
        XCTAssertGreaterThan(score.integer, 0)
        XCTAssertGreaterThan(score.floating, 0)
    }

    func testMemoryAllocationFailure() {
        XCTAssertEqual(Benchmarks.memoryRateText(mbPerSecond: nil), "Memória insuficiente")
        XCTAssertNotEqual(Benchmarks.memoryRateText(mbPerSecond: 100), "Memória insuficiente")
    }
}
