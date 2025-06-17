//
//  WishleApp.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import SwiftUI
import SwiftData
import SubscriptionManager

@main
struct WishleApp: App {
    @StateObject private var subscriptionManager = SubscriptionManager.shared

    var sharedModelContainer: ModelContainer {
        let schema = Schema([
            Item.self,
        ])
        let configuration: ModelConfiguration
        if subscriptionManager.isSubscribed {
            configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        } else {
            configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        }

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .sheet(isPresented: .constant(!subscriptionManager.isSubscribed)) {
                    PaywallView()
                }
                .task { await subscriptionManager.load() }
        }
        .modelContainer(sharedModelContainer)
    }
}
