import Darwin
import Foundation

struct NetworkRates {
    var wifiDown: Double = 0
    var wifiUp: Double = 0
    var cellularDown: Double = 0
    var cellularUp: Double = 0

    var down: Double { wifiDown + cellularDown }
    var up: Double { wifiUp + cellularUp }
}

enum InterfaceKind: Equatable {
    case wifi
    case cellular

    /// `en*` is Wi-Fi and `pdp_ip*` is cellular. Every other interface, loopback included, is ignored.
    static func of(_ name: String) -> InterfaceKind? {
        if name.hasPrefix("en") { return .wifi }
        if name.hasPrefix("pdp_ip") { return .cellular }
        return nil
    }
}

/// Byte totals for the current process session, split by interface kind.
struct SessionTraffic: Equatable {
    private(set) var wifiReceived: UInt64 = 0
    private(set) var wifiSent: UInt64 = 0
    private(set) var cellularReceived: UInt64 = 0
    private(set) var cellularSent: UInt64 = 0

    var totalReceived: UInt64 { wifiReceived + cellularReceived }
    var totalSent: UInt64 { wifiSent + cellularSent }

    mutating func add(name: String, received: UInt64, sent: UInt64) {
        switch InterfaceKind.of(name) {
        case .wifi:
            wifiReceived += received
            wifiSent += sent
        case .cellular:
            cellularReceived += received
            cellularSent += sent
        case nil:
            break
        }
    }
}

/// The Wi-Fi name line. Without location permission the system withholds the name.
enum SSIDLabel {
    static func text(authorized: Bool, ssid: String?) -> String {
        guard authorized else { return "Indisponível" }
        return ssid ?? "Sem conexão"
    }
}

/// Reads per-interface byte counters and turns them into rates and session totals.
final class NetworkSampler {
    private struct Counters { var received: UInt32; var sent: UInt32 }

    private var previous: [String: Counters] = [:]
    private var previousTime: TimeInterval?

    private(set) var session = SessionTraffic()

    var sessionReceived: UInt64 { session.totalReceived }
    var sessionSent: UInt64 { session.totalSent }

    func sample() -> NetworkRates {
        let now = ProcessInfo.processInfo.systemUptime
        let current = Self.readCounters()
        defer {
            previous = current
            previousTime = now
        }
        guard let previousTime, now > previousTime else { return NetworkRates() }

        let elapsed = now - previousTime
        var rates = NetworkRates()
        for (name, counters) in current {
            guard let before = previous[name], let kind = InterfaceKind.of(name) else { continue }
            let received = UInt64(counters.received &- before.received)
            let sent = UInt64(counters.sent &- before.sent)
            session.add(name: name, received: received, sent: sent)
            switch kind {
            case .wifi:
                rates.wifiDown += Double(received) / elapsed
                rates.wifiUp += Double(sent) / elapsed
            case .cellular:
                rates.cellularDown += Double(received) / elapsed
                rates.cellularUp += Double(sent) / elapsed
            }
        }
        return rates
    }

    private static func readCounters() -> [String: Counters] {
        var result: [String: Counters] = [:]
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0 else { return result }
        defer { freeifaddrs(list) }

        var cursor = list
        while let entry = cursor?.pointee {
            defer { cursor = entry.ifa_next }
            let name = String(cString: entry.ifa_name)
            guard InterfaceKind.of(name) != nil,
                  let address = entry.ifa_addr, address.pointee.sa_family == UInt8(AF_LINK),
                  let data = entry.ifa_data
            else { continue }
            let stats = data.load(as: if_data.self)
            result[name] = Counters(received: stats.ifi_ibytes, sent: stats.ifi_obytes)
        }
        return result
    }

    static func ipv4Address(interfacePrefix: String) -> String? {
        var list: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&list) == 0 else { return nil }
        defer { freeifaddrs(list) }

        var cursor = list
        while let entry = cursor?.pointee {
            defer { cursor = entry.ifa_next }
            guard String(cString: entry.ifa_name).hasPrefix(interfacePrefix),
                  let address = entry.ifa_addr, address.pointee.sa_family == UInt8(AF_INET)
            else { continue }
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(address, socklen_t(address.pointee.sa_len), &host, socklen_t(host.count),
                           nil, 0, NI_NUMERICHOST) == 0 {
                return String(cString: host)
            }
        }
        return nil
    }
}
