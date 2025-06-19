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
            WishModel.self,
            TagModel.self
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
            Group {
                if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                    MainTabView()
                } else {
                    OnboardingFlow()
                }
            }
            .task {
                await subscriptionManager.load()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
