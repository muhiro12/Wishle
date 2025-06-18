//
//  WishModel.swift
//  Wishle
//
//  Created by Codex on 2025/06/17.
//

import Foundation
import SwiftData

/// SwiftData model object for persisting wishes.
@Model
final class WishModel: Identifiable, Hashable {
    /// Unique identifier for the wish.
    @Attribute(.unique) var id: UUID
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

    /// Tags associated with the wish. Removing the wish deletes its tags.
    @Relationship(deleteRule: .cascade) var tags: [Tag] = []

    /// Returns true when the due date has passed and the wish is not completed.
    var isOverdue: Bool {
        guard let dueDate else { return false }
        return dueDate < .now && !isCompleted
    }

    init(id: UUID = .init(),
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
}

extension WishModel {
    /// Creates a ``WishModel`` from a ``Wish``.
    convenience init(_ wish: Wish) {
        self.init(
            id: wish.id,
            title: wish.title,
            notes: wish.notes,
            dueDate: wish.dueDate,
            isCompleted: wish.isCompleted,
            priority: wish.priority,
            createdAt: wish.createdAt,
            updatedAt: wish.updatedAt,
            tags: wish.tags
        )
    }

    /// Returns a plain ``Wish`` representation.
    var wish: Wish {
        .init(
            id: id,
            title: title,
            notes: notes,
            dueDate: dueDate,
            isCompleted: isCompleted,
            priority: priority,
            createdAt: createdAt,
            updatedAt: updatedAt,
            tags: tags
        )
    }
}
