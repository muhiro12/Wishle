//
//  TagDetailView.swift
//  Wishle
//
//  Created by Codex on 2025/06/22.
//

import SwiftData
import SwiftUI

struct TagDetailView: View {
    @Environment(Tag.self) private var tag: Tag
    @Environment(\.modelContext) private var modelContext

    @State private var wishes: [Wish] = []

    var body: some View {
        List {
            if wishes.isEmpty {
                Text("No wishes found.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(wishes, id: \.id) { wish in
                    NavigationLink {
                        WishDetailView()
                            .environment(wish)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(wish.title)
                            if let notes = wish.notes {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle(tag.name)
        .task { loadWishes() }
    }

    private func loadWishes() {
        wishes = (try? FetchWishesByTagIntent.perform((
            context: modelContext,
            tagID: tag.id
        ))) ?? []
    }
}

#Preview {
    let container = try! ModelContainer(for: WishModel.self)
    let tag = TagModel(name: "travel")
    let wish = WishModel(title: "Plan a weekend trip", tags: [tag])
    tag.wishes = [wish]
    container.mainContext.insert(tag)
    container.mainContext.insert(wish)
    return NavigationStack {
        TagDetailView()
            .environment(tag.tag)
    }
    .modelContainer(container)
}
