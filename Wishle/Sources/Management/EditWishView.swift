//
//  EditWishView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.
//

import SwiftData
import SwiftUI

struct EditWishView: View {
    let wishModel: WishModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String
    @State private var notes: String
    @State private var isCompleted: Bool
    @State private var priority: Int

    init(wishModel: WishModel) {
        self.wishModel = wishModel
        _title = State(initialValue: wishModel.title)
        _notes = State(initialValue: wishModel.notes ?? "")
        _isCompleted = State(initialValue: wishModel.isCompleted)
        _priority = State(initialValue: wishModel.priority)
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
                context: modelContext,
                id: wishModel.id,
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
    let sample = WishModel(title: "Sample")
    container.mainContext.insert(sample)
    return EditWishView(wishModel: sample)
        .modelContainer(container)
}
