import XCTest
@testable import IphoneInfo

final class ToolBenchTests: XCTestCase {
    func testRegexMatchCountAndFourTools() {
        XCTAssertEqual(ToolBench.regexMatchCount(pattern: "a", text: "banana"), 3)
        XCTAssertEqual(ToolBench.names, ["Decibel", "Régua", "Tom", "Regex"])
    }
}
