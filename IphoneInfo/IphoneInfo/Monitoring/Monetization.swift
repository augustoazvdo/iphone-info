import Foundation

/// What the painel's banner region shows. The region is always present; the message appears on failure.
struct BannerPresentation: Equatable {
    static let failureMessage = "Anúncio indisponível"

    let regionVisible: Bool
    let message: String?

    static func make(loadFailed: Bool) -> BannerPresentation {
        BannerPresentation(regionVisible: true, message: loadFailed ? failureMessage : nil)
    }
}

/// Iphone Info earns from ads only (AD-002). No product is sold, so there is no purchase control.
enum Monetization {
    static let productIdentifiers: [String] = []

    static func purchaseControls(products: [String]) -> [String] {
        products.map { _ in "Comprar" }
    }
}
