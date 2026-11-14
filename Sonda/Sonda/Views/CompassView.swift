import CoreLocation
import Observation
import SwiftUI

@MainActor
@Observable
final class CompassModel: NSObject, CLLocationManagerDelegate {
    private(set) var heading: Double?
    private(set) var authorized = false

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        authorized = Self.isAuthorized(manager.authorizationStatus)
        if authorized { manager.startUpdatingHeading() }
        manager.requestWhenInUseAuthorization()
    }

    func stop() {
        manager.stopUpdatingHeading()
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        MainActor.assumeIsolated {
            authorized = Self.isAuthorized(status)
            if authorized { manager.startUpdatingHeading() }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let value = newHeading.magneticHeading
        MainActor.assumeIsolated {
            heading = value
        }
    }

    private static func isAuthorized(_ status: CLAuthorizationStatus) -> Bool {
        status == .authorizedWhenInUse || status == .authorizedAlways
    }
}

struct CompassView: View {
    @State private var model = CompassModel()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.north.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(-(model.heading ?? 0)))
                .animation(.easeOut(duration: 0.2), value: model.heading)
            Text(CompassReading.text(authorized: model.authorized, headingDegrees: model.heading))
                .font(.title.weight(.bold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Bússola")
        .background { GlassBackdrop() }
        .onDisappear { model.stop() }
    }
}
