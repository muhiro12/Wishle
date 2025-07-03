//
//  Tag.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation

/// In-memory representation of a tag used to categorize wishes.
@Observable
final class Tag {
    /// Unique identifier for the tag.
    var id: String
    /// Lowercased unique name of the tag.
    var name: String {
        didSet {
            let lowercasedName = name.lowercased()
            if name != lowercasedName {
                name = lowercasedName
            }
        }
    }

    init(id: String = UUID().uuidString,
         name: String) {
        self.id = id
        self.name = name.lowercased()
    }

    /// Creates a ``Tag`` from a ``TagModel``.
    convenience init(_ model: TagModel) {
        self.init(id: model.id, name: model.name)
    }

    /// Sample tags for preview usage.
    static func sample() -> [Tag] {
        [
            .init(name: "travel"),
            .init(name: "food"),
            .init(name: "personal"),
            .init(name: "learning")
        ]
    }
}

extension Tag: Equatable {
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }
}
