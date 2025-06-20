//
//  Wish.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation

/// In-memory representation of a wish item.
@Observable
final class Wish: Identifiable, Hashable {
    /// Unique identifier for the wish.
    var id: String
    /// The user-facing title.
    var title: String
    /// Optional notes about the wish.
    var notes: String?
    /// An optional due date.
    var dueDate: Date?
    /// Marks the wish as completed.
    var isCompleted: Bool
    /// Priority level (0 normal, 1 high).
    var priority: Int
    /// Creation timestamp.
    var createdAt: Date
    /// Last update timestamp.
    var updatedAt: Date

    /// Tags associated with the wish.
    var tags: [Tag] = []

    /// Returns true when the due date has passed and the wish is not completed.
    var isOverdue: Bool {
        guard let dueDate else {
            return false
        }
        return dueDate < .now && !isCompleted
    }

    init(id: String = UUID().uuidString,
         title: String,
         notes: String? = nil,
         dueDate: Date? = nil,
         isCompleted: Bool = false,
         priority: Int = 0,
         createdAt: Date = .now,
         updatedAt: Date = .now,
         tags: [Tag] = []) {
        self.id = id
        self.title = title
        self.notes = notes
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
    }

    /// Creates a ``Wish`` from a ``WishModel``.
    init(_ model: WishModel) {
        self.init(
            id: model.id,
            title: model.title,
            notes: model.notes,
            dueDate: model.dueDate,
            isCompleted: model.isCompleted,
            priority: model.priority,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
            tags: model.tags.map(\.tag)
        )
    }
}
