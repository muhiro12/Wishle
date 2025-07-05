//
//  ContentView.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingFlow()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
