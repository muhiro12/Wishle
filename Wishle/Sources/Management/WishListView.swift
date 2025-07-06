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

private enum WishPriorityFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case high = "High"
    case normal = "Normal"

    var id: Self { self }
}

struct WishListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \WishModel.createdAt) private var wishes: [WishModel]
    @Query(sort: \TagModel.name) private var tags: [TagModel]

    @State private var isPresentingAddSheet: Bool = false
    @State private var editingWish: Wish?
    @State private var statusFilter: WishStatusFilter = .all
    @State private var priorityFilter: WishPriorityFilter = .all
    @State private var selectedTagID: String?
    @State private var filteredWishes: [WishModel] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
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
                                if model.priority == 1 {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                if model.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .contextMenu {
                            Button("Edit") {
                                editingWish = .init(model)
                            }
                            Button(model.isCompleted ? "Mark Incomplete" : "Mark Complete") {
                                toggleCompletion(model)
                            }
                            Button("Delete", role: .destructive) {
                                deleteWish(model)
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleCompletion(model)
                            } label: {
                                Label(
                                    model.isCompleted ? "Mark Incomplete" : "Mark Complete",
                                    systemImage: model.isCompleted ? "arrow.uturn.left" : "checkmark"
                                )
                            }
                            .tint(model.isCompleted ? .orange : .green)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Wishes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section("Status") {
                            Picker("Status", selection: $statusFilter) {
                                ForEach(WishStatusFilter.allCases) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }

                        Section("Category") {
                            Picker("Category", selection: $selectedTagID) {
                                Text("All").tag(nil as String?)
                                ForEach(tags) { tag in
                                    Text(tag.name.capitalized).tag(Optional(tag.id))
                                }
                            }
                        }

                        Section("Priority") {
                            Picker("Priority", selection: $priorityFilter) {
                                ForEach(WishPriorityFilter.allCases) { filter in
                                    Text(filter.rawValue).tag(filter)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                }

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
            .sheet(item: $editingWish) { wish in
                EditWishView(wish: wish)
            }
            .onChange(of: statusFilter) { applyFilter() }
            .onChange(of: priorityFilter) { applyFilter() }
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

    private func deleteWish(_ model: WishModel) {
        Task {
            _ = try? DeleteWishIntent.perform((
                context: context,
                id: model.id
            ))
        }
    }

    private func toggleCompletion(_ model: WishModel) {
        Task {
            let isCompleted = !model.isCompleted
            _ = try? UpdateWishIntent.perform((
                context: context,
                id: model.id,
                title: nil,
                notes: nil,
                dueDate: nil,
                isCompleted: isCompleted,
                priority: nil
            ))
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
        switch priorityFilter {
        case .all:
            break
        case .high:
            models = models.filter { $0.priority == 1 }
        case .normal:
            models = models.filter { $0.priority == 0 }
        }
        models.sort { lhs, rhs in
            lhs.priority > rhs.priority
        }
        filteredWishes = models
    }
}

#Preview {
    WishListView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
