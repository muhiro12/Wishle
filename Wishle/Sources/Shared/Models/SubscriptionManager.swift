//
//  SubscriptionManager.swift
//  Wishle
//
//  Created by Codex on 2025/06/17.
//

import Foundation
import StoreKit
import SwiftUI

@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    private(set) var isSubscribed: Bool = false
    private(set) var product: Product?

    private init() {}

    // Loads available subscription status and product.
    func load() async {
        do {
            product = try await Product.products(for: ["com.wishle.subscription"]).first
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   transaction.productID == "com.wishle.subscription" {
                    isSubscribed = true
                    return
                }
            }
            isSubscribed = false
        } catch {
            isSubscribed = false
            product = nil
        }
    }

    // Purchase the subscription.
    func purchase() async throws {
        guard let product else {
            return
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                isSubscribed = true
                await transaction.finish()
            }
        default:
            break
        }
    }

    // Restore purchases.
    func restore() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == "com.wishle.subscription" {
                isSubscribed = true
                return
            }
        }
        isSubscribed = false
    }
}
