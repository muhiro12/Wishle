//
//  AddWishView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.
//

import SwiftData
import SwiftUI

struct AddWishView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var title: String
    @State private var notes: String
    @State private var priority: Int

    init(title: String = "", notes: String = "", priority: Int = 0) {
        _title = State(initialValue: title)
        _notes = State(initialValue: notes)
        _priority = State(initialValue: priority)
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
                Section("Priority") {
                    Stepper(value: $priority, in: 0...1) {
                        Text(priority == 0 ? "Normal" : "High")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Add Wish")
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
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        Task {
            _ = try? AddWishIntent.perform((
                context: context,
                title: title,
                notes: notes.isEmpty ? nil : notes,
                dueDate: nil,
                priority: priority
            ))
            dismiss()
        }
    }
}

#Preview {
    AddWishView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
