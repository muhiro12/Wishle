//
//  WishQuery.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/07/05.
//

import AppIntents
import SwiftData

struct WishQuery: EntityQuery {
    typealias Entity = Wish

    @Dependency private var modelContaienr: ModelContainer

    @MainActor
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
