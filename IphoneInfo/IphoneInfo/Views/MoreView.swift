import SwiftUI

/// Entry point for the measurement and tool screens that do not fit the painel.
struct MoreView: View {
    let monitor: LiveMonitor

    var body: some View {
        List {
            NavigationLink {
                NetworkView(monitor: monitor)
            } label: {
                Label("Rede", systemImage: "network")
            }
            NavigationLink {
                CameraView()
            } label: {
                Label("Câmera", systemImage: "camera")
            }
            NavigationLink {
                SpeedView()
            } label: {
                Label("Velocidade", systemImage: "speedometer")
            }
            NavigationLink {
                BenchmarkView()
            } label: {
                Label("Benchmark", systemImage: "gauge.high")
            }
            NavigationLink {
                DeviceCheckView()
            } label: {
                Label("Checagem", systemImage: "checkmark.seal")
            }
            NavigationLink {
                CompassView()
            } label: {
                Label("Bússola", systemImage: "location.north.line")
            }
            NavigationLink {
                FloatingMeterView(monitor: monitor)
            } label: {
                Label("Medidor flutuante", systemImage: "pip")
            }
            NavigationLink {
                ToolsView()
            } label: {
                Label("Ferramentas", systemImage: "wrench.and.screwdriver")
            }
        }
        .navigationTitle("Mais")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
    }
}
