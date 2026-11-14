import SwiftUI

struct BenchmarkView: View {
    @State private var cpu: Benchmarks.CPUScore?
    @State private var memory: Benchmarks.MemoryRates?
    @State private var memoryFailed = false
    @State private var running = false

    var body: some View {
        List {
            Section {
                Button(running ? "Executando…" : "Executar benchmark") {
                    Task { await run() }
                }
                .buttonStyle(.glassProminent)
                .disabled(running)
            }
            Section(Benchmarks.scoreLabel) {
                if let cpu {
                    ValueRow(label: "Inteiros (milhões/s)", value: "\(cpu.integer)")
                    ValueRow(label: "Ponto flutuante (milhões/s)", value: String(format: "%.1f", cpu.floating))
                } else {
                    Text("Ainda não medido").foregroundStyle(.secondary)
                }
            }
            Section("Memória") {
                if memoryFailed {
                    Text(Benchmarks.allocationFailureText).foregroundStyle(.red)
                } else if let memory {
                    ValueRow(label: "Leitura", value: Benchmarks.memoryRateText(mbPerSecond: memory.readMBps))
                    ValueRow(label: "Escrita", value: Benchmarks.memoryRateText(mbPerSecond: memory.writeMBps))
                    ValueRow(label: "Cópia", value: Benchmarks.memoryRateText(mbPerSecond: memory.copyMBps))
                } else {
                    Text("Ainda não medido").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Benchmark")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
    }

    private func run() async {
        running = true
        let outcome = await Task.detached(priority: .userInitiated) {
            (Benchmarks.measureCPU(), Benchmarks.measureMemory())
        }.value
        cpu = outcome.0
        memory = outcome.1
        memoryFailed = outcome.1 == nil
        running = false
    }
}
