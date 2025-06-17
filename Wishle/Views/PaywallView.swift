//
//  PaywallView.swift
//  Wishle
//
//  Created by Codex on 2025/06/17.
//

import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        VStack(spacing: 24) {
            Text("Wishle Pro")
                .font(.largeTitle.bold())
            Text("Unlock iCloud sync and remove ads.")
                .multilineTextAlignment(.center)
            if let product = subscriptionManager.product {
                Button("Subscribe \(product.displayPrice)") {
                    _Concurrency.Task {
                        try? await subscriptionManager.purchase()
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                ProgressView()
            }
            Button("Restore Purchases") {
                _Concurrency.Task {
                    await subscriptionManager.restore()
                }
            }
            Button("Close") {
                dismiss()
            }
        }
        .padding()
        .task {
            await subscriptionManager.load()
        }
    }
}

#Preview {
    PaywallView()
}
