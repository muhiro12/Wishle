//
//  SettingsView.swift
//  Wishle
//
//  Created by Codex on 2025/06/21.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var isPaywallPresented = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Subscription") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(subscriptionManager.isSubscribed ? "Active" : "Free")
                            .foregroundColor(.secondary)
                    }
                    Button("Manage Subscription") {
                        isPaywallPresented = true
                    }
                }
                Section("Data") {
                    Button("Import Reminders") {
                        Task {
                            try? await ImportRemindersIntent.perform(modelContext)
                        }
                    }
                }
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $isPaywallPresented) {
                PaywallView()
            }
            .task {
                await subscriptionManager.load()
            }
        }
    }
}

#Preview {
    SettingsView()
}
