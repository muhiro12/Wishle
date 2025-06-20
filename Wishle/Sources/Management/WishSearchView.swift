//
//  WishSearchView.swift
//  Wishle
//
//  Created by Codex on 2025/06/21.
//

import SwiftData
import SwiftUI

struct WishSearchView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var query: String = ""
    @State private var results: [Wish] = []

    var body: some View {
        NavigationStack {
            List(results) { wish in
                VStack(alignment: .leading) {
                    Text(wish.title)
                    if let notes = wish.notes {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $query)
            .onSubmit(of: .search) {
                search()
            }
        }
    }

    private func search() {
        Task {
            do {
                results = try SearchWishIntent.perform((context: modelContext, query: query))
            } catch {
                results = []
            }
        }
    }
}

#Preview {
    WishSearchView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
