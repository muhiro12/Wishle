//
//  TagModel.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftData

/// SwiftData model object for persisting tags.
@Model
final class TagModel: Identifiable, Hashable {
    /// Unique identifier for the tag.
    @Attribute(.unique) var id: String
    /// Lowercased unique name of the tag.
    @Attribute(.unique) var name: String {
        didSet {
            let lowercasedName = name.lowercased()
            if name != lowercasedName {
                name = lowercasedName
            }
        }
    }

    /// Wishes that include this tag.
    @Relationship(inverse: \WishModel.tags) var wishes: [WishModel] = []

    init(id: String = UUID().uuidString,
         name: String,
         wishes: [WishModel] = []) {
        self.id = id
        self.name = name.lowercased()
        self.wishes = wishes
    }
}

extension TagModel {
    /// Creates a ``TagModel`` from a ``Tag``.
    convenience init(_ tag: Tag) {
        self.init(id: tag.id, name: tag.name)
    }

    /// Returns a plain ``Tag`` representation.
    var tag: Tag {
        .init(id: id, name: name)
    }
}
