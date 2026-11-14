import SwiftUI

struct SpeedView: View {
    @State private var result: SpeedResult?
    @State private var failed = false
    @State private var running = false

    var body: some View {
        List {
            Section {
                Button(running ? "Medindo…" : "Iniciar teste") {
                    Task { await measure() }
                }
                .buttonStyle(.glassProminent)
                .disabled(running)
            }
            Section("Resultado") {
                if failed {
                    Text(SpeedTest.failureText).foregroundStyle(.red)
                } else if let result {
                    ValueRow(label: "Ping", value: "\(Int(result.pingMilliseconds.rounded())) ms")
                    ValueRow(label: "Download", value: SpeedTest.rateText(bytesPerSecond: result.downloadBytesPerSecond))
                    ValueRow(label: "Upload", value: SpeedTest.rateText(bytesPerSecond: result.uploadBytesPerSecond))
                } else {
                    Text("Ainda não medido").foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Velocidade")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
    }

    private func measure() async {
        running = true
        failed = false
        do {
            result = try await SpeedTest.run()
        } catch {
            result = nil
            failed = true
        }
        running = false
    }
}
