//
//  WishListView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.
//

import SwiftData
import SwiftUI

struct WishListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WishModel.createdAt) private var wishes: [WishModel]

    @State private var isPresentingAddSheet: Bool = false
    @State private var editingWish: WishModel?

    var body: some View {
        NavigationStack {
            List {
                ForEach(wishes) { model in
                    NavigationLink {
                        WishDetailView()
                            .environment(model.wish)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(model.title)
                                if let notes = model.notes {
                                    Text(notes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            if model.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .contextMenu {
                        Button("Edit") {
                            editingWish = model
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Wishes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresentingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddWishView()
            }
            .sheet(item: $editingWish) { model in
                EditWishView(wishModel: model)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let model = wishes[index]
            Task {
                _ = try? DeleteWishIntent.perform((
                    context: context,
                    id: model.id
                ))
            }
        }
    }
}

#Preview {
    WishListView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
