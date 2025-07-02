//
//  WishEntityQuery.swift
//  Wishle
//
//  Created by Codex on 2025/06/29.
//

import AppIntents
import SwiftData

struct WishEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [Wish.ID]) throws -> [Wish] {
        try identifiers.compactMap { id in
            let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
            return try modelContainer.mainContext.fetch(descriptor).first?.wish
        }
    }

    @MainActor
    func entities(matching string: String) throws -> [Wish] {
        try modelContainer.mainContext
            .fetch(FetchDescriptor<WishModel>(predicate: #Predicate { $0.title.localizedStandardContains(string) }))
            .map(\.wish)
    }

    @MainActor
    func suggestedEntities() throws -> [Wish] {
        try modelContainer.mainContext.fetch(FetchDescriptor<WishModel>()).map(\.wish)
    }
}

