import Darwin
import Foundation
import Metal
import UIKit

enum Sysctl {
    static func string(_ name: String) -> String? {
        var size = 0
        guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else { return nil }
        var buffer = [CChar](repeating: 0, count: size)
        guard sysctlbyname(name, &buffer, &size, nil, 0) == 0 else { return nil }
        return String(cString: buffer)
    }

    static func integer(_ name: String) -> Int? {
        var value: Int64 = 0
        var size = MemoryLayout<Int64>.size
        guard sysctlbyname(name, &value, &size, nil, 0) == 0 else { return nil }
        // Some keys are 32-bit; the unused high bytes stay zero.
        return Int(value)
    }

    static func bootDate() -> Date? {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.size
        guard sysctlbyname("kern.boottime", &boottime, &size, nil, 0) == 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec))
    }
}

struct CoreLayout {
    let performance: Int?
    let efficiency: Int?
    let logical: Int

    static func current() -> CoreLayout {
        let levels = Sysctl.integer("hw.nperflevels") ?? 0
        return CoreLayout(
            performance: levels >= 1 ? Sysctl.integer("hw.perflevel0.physicalcpu") : nil,
            efficiency: levels >= 2 ? Sysctl.integer("hw.perflevel1.physicalcpu") : nil,
            logical: ProcessInfo.processInfo.activeProcessorCount)
    }
}

struct GPUInfo {
    let name: String
    let family: String?
    let supportsRayTracing: Bool
    let recommendedWorkingSet: UInt64

    static func current() -> GPUInfo? {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        let families: [(MTLGPUFamily, String)] = [
            (.apple9, "Apple 9"), (.apple8, "Apple 8"), (.apple7, "Apple 7"), (.apple6, "Apple 6"),
        ]
        return GPUInfo(
            name: device.name,
            family: families.first { device.supportsFamily($0.0) }?.1,
            supportsRayTracing: device.supportsRaytracing,
            recommendedWorkingSet: device.recommendedMaxWorkingSetSize)
    }
}

struct SystemInfo {
    let modelIdentifier: String
    let spec: DeviceSpec?
    let deviceName: String
    let systemName: String
    let systemVersion: String
    let buildNumber: String?
    let kernelVersion: String?
    let bootDate: Date?
    let cores: CoreLayout
    let l1DataCache: Int?
    let l2Cache: Int?
    let physicalMemory: UInt64
    let gpu: GPUInfo?
    let screenPixels: CGSize
    let screenScale: CGFloat
    let maxFramesPerSecond: Int

    var displayName: String { spec?.name ?? modelIdentifier }

    @MainActor
    static func current() -> SystemInfo {
        let device = UIDevice.current
        let screen = UIScreen.main
        let identifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"]
            ?? Sysctl.string("hw.machine") ?? "Desconhecido"

        return SystemInfo(
            modelIdentifier: identifier,
            spec: DeviceCatalog.spec(for: identifier),
            deviceName: device.name,
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            buildNumber: Sysctl.string("kern.osversion"),
            kernelVersion: Sysctl.string("kern.osrelease"),
            bootDate: Sysctl.bootDate(),
            cores: .current(),
            l1DataCache: Sysctl.integer("hw.perflevel0.l1dcachesize") ?? Sysctl.integer("hw.l1dcachesize"),
            l2Cache: Sysctl.integer("hw.perflevel0.l2cachesize") ?? Sysctl.integer("hw.l2cachesize"),
            physicalMemory: ProcessInfo.processInfo.physicalMemory,
            gpu: .current(),
            screenPixels: screen.nativeBounds.size,
            screenScale: screen.nativeScale,
            maxFramesPerSecond: screen.maximumFramesPerSecond)
    }
}
