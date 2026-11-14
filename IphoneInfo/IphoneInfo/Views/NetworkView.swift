import CoreLocation
import NetworkExtension
import SwiftUI

struct NetworkView: View {
    let monitor: LiveMonitor

    @State private var location = CLLocationManager()
    @State private var ssid: String?

    private var ssidAuthorized: Bool {
        [.authorizedWhenInUse, .authorizedAlways].contains(location.authorizationStatus)
    }

    var body: some View {
        List {
            Section("Wi-Fi") {
                ValueRow(label: "Download total", value: Format.storage(Int64(monitor.session.wifiReceived)))
                ValueRow(label: "Upload total", value: Format.storage(Int64(monitor.session.wifiSent)))
            }
            Section("Celular") {
                ValueRow(label: "Download total", value: Format.storage(Int64(monitor.session.cellularReceived)))
                ValueRow(label: "Upload total", value: Format.storage(Int64(monitor.session.cellularSent)))
            }
            Section("Wi-Fi atual") {
                ValueRow(label: "Nome da rede", value: SSIDLabel.text(authorized: ssidAuthorized, ssid: ssid))
            }
        }
        .navigationTitle("Rede")
        .scrollContentBackground(.hidden)
        .background { GlassBackdrop() }
        .onAppear {
            location.requestWhenInUseAuthorization()
        }
        .task {
            ssid = await NEHotspotNetwork.fetchCurrent()?.ssid
        }
    }
}

private extension NEHotspotNetwork {
    /// Returns the current network, or nil when the Wi-Fi info entitlement is missing or no Wi-Fi is joined.
    static func fetchCurrent() async -> NEHotspotNetwork? {
        await withCheckedContinuation { continuation in
            NEHotspotNetwork.fetchCurrent { network in
                continuation.resume(returning: network)
            }
        }
    }
}
