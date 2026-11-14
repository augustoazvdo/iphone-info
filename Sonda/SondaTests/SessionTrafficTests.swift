import XCTest
@testable import Sonda

final class SessionTrafficTests: XCTestCase {
    func testSessionTotalsSplitWifiAndCellular() {
        var traffic = SessionTraffic()
        traffic.add(name: "en0", received: 100, sent: 0)
        traffic.add(name: "pdp_ip0", received: 50, sent: 0)
        traffic.add(name: "lo0", received: 999, sent: 999)
        XCTAssertEqual(traffic.wifiReceived, 100)
        XCTAssertEqual(traffic.cellularReceived, 50)
        XCTAssertEqual(traffic.totalReceived, 150)
        XCTAssertEqual(traffic.totalSent, 0)
    }

    func testDeniedLocationHidesSsid() {
        XCTAssertEqual(SSIDLabel.text(authorized: false, ssid: "Casa"), "Indisponível")
        XCTAssertEqual(SSIDLabel.text(authorized: true, ssid: "Casa"), "Casa")
    }
}
