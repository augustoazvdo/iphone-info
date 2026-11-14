import GoogleMobileAds
import SwiftUI

@main
struct SondaApp: App {
    init() {
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    @State private var monitor = LiveMonitor()
    @State private var system = SystemInfo.current()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            Tab("Painel", systemImage: "gauge.with.dots.needle.67percent") {
                NavigationStack { DashboardView(monitor: monitor, system: system) }
            }
            Tab("Dispositivo", systemImage: "iphone") {
                NavigationStack { DeviceView(system: system) }
            }
            Tab("Sensores", systemImage: "sensor") {
                NavigationStack { SensorsView() }
            }
            Tab("Mais", systemImage: "ellipsis.circle") {
                NavigationStack { MoreView(monitor: monitor) }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .task {
            monitor.capacityMilliampHours = system.spec?.capacityMilliampHours
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if SampleGate.runs(active: phase == .active) { monitor.start() } else { monitor.stop() }
        }
    }
}
