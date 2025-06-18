//
//  Tag.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftData

/// A tag used to categorize wishes.
@Model
final class Tag: Identifiable, Hashable {
    /// Unique identifier for the tag.
    @Attribute(.unique) var id: UUID
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

    init(id: UUID = .init(),
         name: String,
         wishes: [WishModel] = []) {
        self.id = id
        self.name = name.lowercased()
        self.wishes = wishes
    }

    /// Sample tags for preview usage.
    static func sample() -> [Tag] {
        [
            .init(name: "home"),
            .init(name: "work"),
            .init(name: "urgent")
        ]
    }
}
