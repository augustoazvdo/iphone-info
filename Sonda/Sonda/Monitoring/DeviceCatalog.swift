struct ChipSpec {
    let name: String
    let process: String
    let maxClockGHz: Double
    let gpuCores: Int
}

struct DeviceSpec {
    let name: String
    let chip: ChipSpec
    /// Nominal battery capacity in mAh from published teardown and certification figures.
    let capacityMilliampHours: Int
}

/// Public launch specifications keyed by `hw.machine`. Core counts are read live from sysctl.
enum DeviceCatalog {
    private static let a14 = ChipSpec(name: "Apple A14 Bionic", process: "5 nm (TSMC N5)", maxClockGHz: 3.0, gpuCores: 4)
    private static let a15FourGPU = ChipSpec(name: "Apple A15 Bionic", process: "5 nm (TSMC N5P)", maxClockGHz: 3.23, gpuCores: 4)
    private static let a15FiveGPU = ChipSpec(name: "Apple A15 Bionic", process: "5 nm (TSMC N5P)", maxClockGHz: 3.23, gpuCores: 5)
    private static let a16 = ChipSpec(name: "Apple A16 Bionic", process: "4 nm (TSMC N4P)", maxClockGHz: 3.46, gpuCores: 5)
    private static let a17Pro = ChipSpec(name: "Apple A17 Pro", process: "3 nm (TSMC N3B)", maxClockGHz: 3.78, gpuCores: 6)
    private static let a18FourGPU = ChipSpec(name: "Apple A18", process: "3 nm (TSMC N3E)", maxClockGHz: 4.04, gpuCores: 4)
    private static let a18 = ChipSpec(name: "Apple A18", process: "3 nm (TSMC N3E)", maxClockGHz: 4.04, gpuCores: 5)
    private static let a18Pro = ChipSpec(name: "Apple A18 Pro", process: "3 nm (TSMC N3E)", maxClockGHz: 4.05, gpuCores: 6)

    private static let models: [String: DeviceSpec] = [
        "iPhone13,1": DeviceSpec(name: "iPhone 12 mini", chip: a14, capacityMilliampHours: 2227),
        "iPhone13,2": DeviceSpec(name: "iPhone 12", chip: a14, capacityMilliampHours: 2815),
        "iPhone13,3": DeviceSpec(name: "iPhone 12 Pro", chip: a14, capacityMilliampHours: 2815),
        "iPhone13,4": DeviceSpec(name: "iPhone 12 Pro Max", chip: a14, capacityMilliampHours: 3687),
        "iPhone14,4": DeviceSpec(name: "iPhone 13 mini", chip: a15FourGPU, capacityMilliampHours: 2406),
        "iPhone14,5": DeviceSpec(name: "iPhone 13", chip: a15FourGPU, capacityMilliampHours: 3227),
        "iPhone14,2": DeviceSpec(name: "iPhone 13 Pro", chip: a15FiveGPU, capacityMilliampHours: 3095),
        "iPhone14,3": DeviceSpec(name: "iPhone 13 Pro Max", chip: a15FiveGPU, capacityMilliampHours: 4352),
        "iPhone14,6": DeviceSpec(name: "iPhone SE (3ª geração)", chip: a15FourGPU, capacityMilliampHours: 2018),
        "iPhone14,7": DeviceSpec(name: "iPhone 14", chip: a15FiveGPU, capacityMilliampHours: 3279),
        "iPhone14,8": DeviceSpec(name: "iPhone 14 Plus", chip: a15FiveGPU, capacityMilliampHours: 4325),
        "iPhone15,2": DeviceSpec(name: "iPhone 14 Pro", chip: a16, capacityMilliampHours: 3200),
        "iPhone15,3": DeviceSpec(name: "iPhone 14 Pro Max", chip: a16, capacityMilliampHours: 4323),
        "iPhone15,4": DeviceSpec(name: "iPhone 15", chip: a16, capacityMilliampHours: 3349),
        "iPhone15,5": DeviceSpec(name: "iPhone 15 Plus", chip: a16, capacityMilliampHours: 4383),
        "iPhone16,1": DeviceSpec(name: "iPhone 15 Pro", chip: a17Pro, capacityMilliampHours: 3274),
        "iPhone16,2": DeviceSpec(name: "iPhone 15 Pro Max", chip: a17Pro, capacityMilliampHours: 4422),
        "iPhone17,1": DeviceSpec(name: "iPhone 16 Pro", chip: a18Pro, capacityMilliampHours: 3582),
        "iPhone17,2": DeviceSpec(name: "iPhone 16 Pro Max", chip: a18Pro, capacityMilliampHours: 4685),
        "iPhone17,3": DeviceSpec(name: "iPhone 16", chip: a18, capacityMilliampHours: 3561),
        "iPhone17,4": DeviceSpec(name: "iPhone 16 Plus", chip: a18, capacityMilliampHours: 4674),
        "iPhone17,5": DeviceSpec(name: "iPhone 16e", chip: a18FourGPU, capacityMilliampHours: 4005),
    ]

    static func spec(for identifier: String) -> DeviceSpec? {
        models[identifier]
    }
}
