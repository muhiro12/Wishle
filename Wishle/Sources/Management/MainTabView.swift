//
//  MainTabView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.
//

import SwiftData
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
            WishListView()
                .tabItem {
                    Label("Wishes", systemImage: "list.bullet")
                }
            WishSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            WishSuggestionView()
                .tabItem {
                    Label("Suggest", systemImage: "lightbulb")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
