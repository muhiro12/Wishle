//
//  WishleApp.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import SwiftUI
import SwiftData

@main
struct WishleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
                ContentView()
            } else {
                OnboardingFlow()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
