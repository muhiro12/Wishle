import Foundation
import StoreKit

@MainActor
public final class SubscriptionManager: ObservableObject {
    public static let shared = SubscriptionManager()

    @Published public private(set) var product: Product?
    @Published public private(set) var isSubscribed = false

    public var productID = "wishle.pro.annual"

    private init() {}

    public func load() async {
        await requestProduct()
        await updateSubscriptionStatus()
    }

    public func requestProduct() async {
        do {
            product = try await Product.products(for: [productID]).first
        } catch {
            product = nil
        }
    }

    public func updateSubscriptionStatus() async {
        do {
            isSubscribed = try await checkStatus()
        } catch {
            isSubscribed = false
        }
    }

    private func checkStatus() async throws -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID,
               transaction.revocationDate == nil {
                if let expiration = transaction.expirationDate {
                    if expiration > .now {
                        return true
                    }
                } else {
                    return true
                }
            }
        }
        return false
    }

    public func purchase() async throws {
        guard let product else { return }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                isSubscribed = true
            }
        default:
            break
        }
    }

    public func restore() async {
        try? await AppStore.sync()
        await updateSubscriptionStatus()
    }
}
