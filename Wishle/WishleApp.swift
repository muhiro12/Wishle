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
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isOnboardingPresented: Bool
    @State private var isPaywallPresented = false

    init() {
        _isOnboardingPresented = State(initialValue: !hasSeenOnboarding)
    }

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
            ContentView()
                .sheet(isPresented: $isPaywallPresented) {
                    PaywallView()
                }
                .fullScreenCover(isPresented: $isOnboardingPresented) {
                    OnboardingFlow()
                }
                .task {
                    await subscriptionManager.load()
                    isPaywallPresented = !subscriptionManager.isSubscribed
                }
                .onReceive(subscriptionManager.$isSubscribed) { isSubscribed in
                    isPaywallPresented = !isSubscribed
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
