//
//  TagQuery.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/18.
//

import AppIntents

public struct TagQuery: EntityQuery {
    public init() {}
    public func entities(for _: [Tag.ID]) throws -> [Tag] { [] }
    public func suggestedEntities() throws -> [Tag] { [] }
}
