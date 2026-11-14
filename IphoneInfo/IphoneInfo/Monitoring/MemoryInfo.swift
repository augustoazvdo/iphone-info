import Darwin
import Foundation

struct MemorySnapshot {
    let total: UInt64
    let free: UInt64
    let active: UInt64
    let inactive: UInt64
    let wired: UInt64
    let compressed: UInt64

    var used: UInt64 { active + wired + compressed }
    var usedFraction: Double { total > 0 ? min(Double(used) / Double(total), 1) : 0 }

    static func current() -> MemorySnapshot? {
        var pageSize: vm_size_t = 0
        guard host_page_size(mach_host_self(), &pageSize) == KERN_SUCCESS else { return nil }

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }

        let page = UInt64(pageSize)
        return MemorySnapshot(
            total: ProcessInfo.processInfo.physicalMemory,
            free: UInt64(stats.free_count) * page,
            active: UInt64(stats.active_count) * page,
            inactive: UInt64(stats.inactive_count) * page,
            wired: UInt64(stats.wire_count) * page,
            compressed: UInt64(stats.compressor_page_count) * page)
    }
}

struct StorageSnapshot {
    let total: Int64
    let available: Int64

    var used: Int64 { max(total - available, 0) }
    var usedFraction: Double { total > 0 ? Double(used) / Double(total) : 0 }

    static func current() -> StorageSnapshot? {
        let keys: Set<URLResourceKey> = [.volumeTotalCapacityKey, .volumeAvailableCapacityForImportantUsageKey]
        guard let values = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: keys),
              let total = values.volumeTotalCapacity,
              let available = values.volumeAvailableCapacityForImportantUsage
        else { return nil }
        return StorageSnapshot(total: Int64(total), available: available)
    }
}
