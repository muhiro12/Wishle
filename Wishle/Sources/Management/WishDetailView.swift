//
//  WishDetailView.swift
//  Wishle
//
//  Created by Codex on 2025/06/22.
//

import SwiftData
import SwiftUI

struct WishDetailView: View {
    @Environment(Wish.self) private var wish: Wish
    @Environment(\.modelContext) private var modelContext

    @State private var editingWish: Wish?

    var body: some View {
        List {
            if let notes = wish.notes {
                Section("Notes") {
                    Text(notes)
                }
            }
            if let dueDate = wish.dueDate {
                Section("Due Date") {
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                }
            }
            Section("Completed") {
                Text(wish.isCompleted ? "Yes" : "No")
            }
            Section("Priority") {
                Text(wish.priority == 0 ? "Normal" : "High")
            }
            if !wish.tags.isEmpty {
                Section("Tags") {
                    ForEach(wish.tags, id: \.id) { tag in
                        NavigationLink {
                            TagDetailView()
                                .environment(tag)
                        } label: {
                            Text(tag.name)
                        }
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(wish.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    loadModel()
                }
            }
        }
        .sheet(item: $editingWish) { wish in
            EditWishView(wish: wish)
        }
    }

    private func loadModel() {
        editingWish = try? FetchWishIntent.perform((
            context: modelContext,
            id: wish.id
        ))
    }
}

#Preview {
    let container = try! ModelContainer(for: WishModel.self)
    let sample = WishModel(title: "Plan a weekend trip")
    container.mainContext.insert(sample)
    return NavigationStack {
        WishDetailView()
            .environment(sample.wish)
    }
    .modelContainer(container)
}
