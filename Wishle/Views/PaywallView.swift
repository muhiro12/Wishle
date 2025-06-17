//
//  PaywallView.swift
//  Wishle
//
//  Created by Codex on 2025/06/17.
//

import SwiftUI
import StoreKit
import SubscriptionManager

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        VStack(spacing: 24) {
            Text("Wishle Pro")
                .font(.largeTitle.bold())
            Text("Unlock iCloud sync and remove ads.")
                .multilineTextAlignment(.center)
            if let product = subscriptionManager.product {
                Button("Subscribe \(product.displayPrice)") {
                    Task { try? await subscriptionManager.purchase() }
                }
                .buttonStyle(.borderedProminent)
            } else {
                ProgressView()
            }
            Button("Restore Purchases") {
                Task { await subscriptionManager.restore() }
            }
            Button("Close") { dismiss() }
        }
        .padding()
        .task { await subscriptionManager.load() }
    }
}

#Preview {
    PaywallView()
}
