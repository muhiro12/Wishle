//
//  TagQuery.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/07/05.
//

import AppIntents
import SwiftData

struct TagQuery: EntityQuery {
    typealias Entity = Tag

    @Dependency var modelContaienr: ModelContainer

    func entities(for identifiers: [Entity.ID]) throws -> [Entity] {
        try modelContaienr.mainContext.fetch(
            .init(
                predicate: #Predicate { model in
                    identifiers.contains {
                        $0 == model.id
                    }
                }
            )
        )
        .compactMap(Entity.init)
    }
}
