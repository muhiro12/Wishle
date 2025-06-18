//
//  Wish.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftData
import AppIntents

/// A wish item within Wishle.
@Model
final class Wish: Identifiable, Hashable, AppEntity {
    static let defaultQuery = WishEntityQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(
            name: .init("Wish", table: "AppIntents"),
            numericFormat: LocalizedStringResource("\(placeholder: .int) Wishes", table: "AppIntents")
        )
    }

    var displayRepresentation: DisplayRepresentation {
        .init(
            title: .init(title, table: "AppIntents"),
            subtitle: notes.map { .init($0, table: "AppIntents") },
            image: .init(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
        )
    }
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
