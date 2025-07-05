//
//  Wish.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import Foundation
import SwiftUtilities

/// In-memory representation of a wish item.
@Observable
nonisolated final class Wish {
    /// Unique identifier for the wish.
    let id: String
    /// The user-facing title.
    let title: String
    /// Optional notes about the wish.
    let notes: String?
    /// An optional due date.
    let dueDate: Date?
    /// Marks the wish as completed.
    let isCompleted: Bool
    /// Priority level (0 normal, 1 high).
    let priority: Int
    /// Creation timestamp.
    let createdAt: Date
    /// Last update timestamp.
    let updatedAt: Date

    /// Tags associated with the wish.
    let tags: [Tag]

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
}

extension Wish: AppEntity {
    static let defaultQuery = WishQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: LocalizedStringResource("Wish"))
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: .init(stringLiteral: title))
    }
}

extension Wish: ModelBridgeable {
    typealias Model = WishModel

    convenience init?(_ model: WishModel) {
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
