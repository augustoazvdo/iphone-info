import GoogleMobileAds
import SwiftUI
import UIKit

/// One standard banner. `loadFailed` turns true when the SDK reports no fill or an error.
struct AdBannerView: UIViewRepresentable {
    @Binding var loadFailed: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(loadFailed: $loadFailed)
    }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdUnits.bannerUnitID
        banner.delegate = context.coordinator
        banner.rootViewController = Self.rootViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    @MainActor
    final class Coordinator: NSObject, BannerViewDelegate {
        private let loadFailed: Binding<Bool>

        init(loadFailed: Binding<Bool>) {
            self.loadFailed = loadFailed
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            loadFailed.wrappedValue = false
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            loadFailed.wrappedValue = true
        }
    }
}
