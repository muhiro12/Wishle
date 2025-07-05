//
//  Tag.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import Foundation
import SwiftUtilities

/// In-memory representation of a tag used to categorize wishes.
@Observable
nonisolated final class Tag {
    /// Unique identifier for the tag.
    let id: String
    /// Lowercased unique name of the tag.
    let name: String

    init(id: String = UUID().uuidString,
         name: String) {
        self.id = id
        self.name = name.lowercased()
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

extension Tag: AppEntity {
    static let defaultQuery = TagQuery()

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Tag")
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: .init(stringLiteral: name))
    }
}

extension Tag: ModelBridgeable {
    typealias Model = TagModel

    convenience init?(_ model: TagModel) {
        self.init(id: model.id, name: model.name)
    }
}
