//
//  WishleApp.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import SwiftData
import SwiftUI

@main
struct WishleApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    var sharedModelContainer: ModelContainer {
        let schema = Schema([
            Item.self
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
            if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                ContentView()
                    .sheet(isPresented: .constant(!subscriptionManager.isSubscribed)) {
                        PaywallView()
                    }
                    .task { await subscriptionManager.load() }
            } else {
                OnboardingFlow()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
