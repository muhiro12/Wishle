//
//  EditWishView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.
//

import SwiftData
import SwiftUI

struct EditWishView: View {
    let wish: Wish
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title: String
    @State private var notes: String
    @State private var isCompleted: Bool
    @State private var priority: Int

    init(wish: Wish) {
        self.wish = wish
        _title = State(initialValue: wish.title)
        _notes = State(initialValue: wish.notes ?? "")
        _isCompleted = State(initialValue: wish.isCompleted)
        _priority = State(initialValue: wish.priority)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Title", text: $title)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes)
                }
                Section("Completed") {
                    Toggle("Completed", isOn: $isCompleted)
                }
                Section("Priority") {
                    Stepper(value: $priority, in: 0...1) {
                        Text(priority == 0 ? "Normal" : "High")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit Wish")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
        }
    }

    private func save() {
        Task {
            _ = try? UpdateWishIntent.perform((
                context: context,
                id: wish.id,
                title: title,
                notes: notes.isEmpty ? nil : notes,
                dueDate: nil,
                isCompleted: isCompleted,
                priority: priority
            ))
            dismiss()
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: WishModel.self)
    let sample = WishModel(title: "Plan a weekend trip")
    container.mainContext.insert(sample)
    return EditWishView(wish: .init(sample)!)
        .modelContainer(container)
}
