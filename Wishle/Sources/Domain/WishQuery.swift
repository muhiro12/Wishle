//
//  WishQuery.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/18.
//

import AppIntents

public struct WishQuery: EntityQuery {
    public init() {}
    public func entities(for _: [Wish.ID]) throws -> [Wish] { [] }
    public func suggestedEntities() throws -> [Wish] { [] }
}
