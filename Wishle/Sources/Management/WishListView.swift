//
//  WishListView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.
//

import SwiftData
import SwiftUI

private enum WishStatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case completed = "Completed"
    case incomplete = "Incomplete"

    var id: Self { self }
}

struct WishListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WishModel.createdAt) private var wishes: [WishModel]
    @Query(sort: \TagModel.name) private var tags: [TagModel]

    @State private var isPresentingAddSheet: Bool = false
    @State private var editingWish: WishModel?
    @State private var statusFilter: WishStatusFilter = .all
    @State private var selectedTagID: String?
    @State private var filteredWishes: [WishModel] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Status", selection: $statusFilter) {
                    ForEach(WishStatusFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Category", selection: $selectedTagID) {
                    Text("All").tag(nil as String?)
                    ForEach(tags) { tag in
                        Text(tag.name.capitalized).tag(Optional(tag.id))
                    }
                }
                .pickerStyle(.menu)

                List {
                    ForEach(filteredWishes) { model in
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
                .scrollDismissesKeyboard(.interactively)
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
            .onChange(of: statusFilter) { applyFilter() }
            .onChange(of: selectedTagID) { applyFilter() }
            .onChange(of: wishes) { applyFilter() }
            .task { applyFilter() }
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

    private func applyFilter() {
        var models = wishes
        switch statusFilter {
        case .all:
            break
        case .completed:
            models = models.filter(\.isCompleted)
        case .incomplete:
            models = models.filter { !$0.isCompleted }
        }
        if let tagID = selectedTagID {
            models = models.filter { model in
                model.tags.contains { $0.id == tagID }
            }
        }
        filteredWishes = models
    }
}

#Preview {
    WishListView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
