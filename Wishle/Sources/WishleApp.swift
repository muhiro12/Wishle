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
    @State private var notificationManager = NotificationManager.shared
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

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
                if hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingFlow()
                }
            }
            .task {
                await subscriptionManager.load()
            }
            .task {
                await notificationManager.requestAuthorization()
                notificationManager.recordLaunch()
                notificationManager.scheduleDailySuggestion()
                notificationManager.scheduleLaunchBasedSuggestion()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
