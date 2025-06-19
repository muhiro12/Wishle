//
//  MainTabView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.
//

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
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: WishModel.self, inMemory: true)
}

