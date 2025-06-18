//
//  WishModel.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftData

@Model
final class WishModel {
    @Attribute(.unique) private(set) var id: UUID = .init()
    private(set) var title = String()
    private(set) var notes: String?
    private(set) var dueDate: Date?
    private(set) var isCompleted = false
    private(set) var priority = 0
    private(set) var createdAt = Date.now
    private(set) var updatedAt = Date.now
    @Relationship(deleteRule: .cascade, inverse: \Tag.wishes) private(set) var tags: [Tag] = []

    private init() {}

    static func create(context: ModelContext,
                       title: String,
                       notes: String?,
                       dueDate: Date?,
                       priority: Int) -> WishModel {
        let model = WishModel()
        context.insert(model)
        model.title = title
        model.notes = notes
        model.dueDate = dueDate
        model.priority = priority
        return model
    }

    func update(from wish: Wish) {
        title = wish.title
        notes = wish.notes
        dueDate = wish.dueDate
        isCompleted = wish.isCompleted
        priority = wish.priority
        updatedAt = wish.updatedAt
        tags = wish.tags
    }
}

extension WishModel {
    var wish: Wish {
        .init(id: id,
              title: title,
              notes: notes,
              dueDate: dueDate,
              isCompleted: isCompleted,
              priority: priority,
              createdAt: createdAt,
              updatedAt: updatedAt,
              tags: tags)
    }
}
