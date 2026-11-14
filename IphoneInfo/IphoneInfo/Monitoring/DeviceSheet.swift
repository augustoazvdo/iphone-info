import Foundation

/// The dispositivo screen rows, built from `SystemInfo`. Missing hardware shows a fixed word, not a guess.
enum DeviceSheet {
    static func make(system: SystemInfo) -> [SheetSection] {
        let chip = system.spec?.chip

        var processor = [SheetRow(label: "Chip", value: chip?.name ?? "Desconhecido")]
        if let chip {
            processor.append(SheetRow(label: "Processo", value: chip.process))
            processor.append(SheetRow(label: "Frequência máxima", value: String(format: "%.2f GHz", chip.maxClockGHz)))
        }
        processor.append(SheetRow(label: "Núcleos lógicos", value: "\(system.cores.logical)"))
        if let performance = system.cores.performance {
            processor.append(SheetRow(label: "Núcleos de desempenho", value: "\(performance)"))
        }
        if let efficiency = system.cores.efficiency {
            processor.append(SheetRow(label: "Núcleos de eficiência", value: "\(efficiency)"))
        }
        if let l1 = system.l1DataCache {
            processor.append(SheetRow(label: "Cache L1 de dados", value: Format.bytes(l1)))
        }
        if let l2 = system.l2Cache {
            processor.append(SheetRow(label: "Cache L2", value: Format.bytes(l2)))
        }

        let gpuRows: [SheetRow]
        if let gpu = system.gpu {
            var rows = [SheetRow(label: "Nome", value: gpu.name)]
            if let cores = chip?.gpuCores {
                rows.append(SheetRow(label: "Núcleos", value: "\(cores)"))
            }
            if let family = gpu.family {
                rows.append(SheetRow(label: "Família Metal", value: family))
            }
            rows.append(SheetRow(label: "Ray tracing", value: gpu.supportsRayTracing ? "Sim" : "Não"))
            rows.append(SheetRow(label: "Memória recomendada", value: Format.bytes(gpu.recommendedWorkingSet)))
            gpuRows = rows
        } else {
            gpuRows = [SheetRow(label: "GPU", value: "Metal indisponível")]
        }

        var sections = [
            SheetSection(title: "Dispositivo", rows: [
                SheetRow(label: "Modelo", value: system.displayName),
                SheetRow(label: "Identificador", value: system.modelIdentifier),
                SheetRow(label: "Nome", value: system.deviceName),
            ]),
            SheetSection(title: "Processador", rows: processor),
            SheetSection(title: "GPU", rows: gpuRows),
            SheetSection(title: "Memória", rows: [
                SheetRow(label: "RAM física", value: Format.bytes(system.physicalMemory)),
            ]),
            SheetSection(title: "Tela", rows: [
                SheetRow(label: "Resolução", value: "\(Int(system.screenPixels.width)) × \(Int(system.screenPixels.height)) px"),
                SheetRow(label: "Escala", value: String(format: "@%.0fx", system.screenScale)),
                SheetRow(label: "Taxa de atualização máxima", value: "\(system.maxFramesPerSecond) Hz"),
            ]),
        ]

        var software = [
            SheetRow(label: "Versão", value: "\(system.systemName) \(system.systemVersion)"),
        ]
        if let build = system.buildNumber {
            software.append(SheetRow(label: "Build", value: build))
        }
        if let kernel = system.kernelVersion {
            software.append(SheetRow(label: "Kernel Darwin", value: kernel))
        }
        if let boot = system.bootDate {
            software.append(SheetRow(label: "Ligado há", value: Format.duration(since: boot)))
        }
        sections.append(SheetSection(title: "Sistema", rows: software))
        return sections
    }
}
