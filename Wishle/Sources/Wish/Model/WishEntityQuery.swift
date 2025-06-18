//
//  WishEntityQuery.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftData

struct WishEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [Wish.ID]) throws -> [Wish] {
        try identifiers.compactMap { identifier in
            let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == identifier })
            return try modelContainer.mainContext.fetch(descriptor).first.map(Wish.init)
        }
    }

    @MainActor
    func entities(matching string: String) throws -> [Wish] {
        try modelContainer.mainContext.fetch(
            FetchDescriptor<WishModel>(predicate: #Predicate { $0.title.localizedStandardContains(string) })
        ).map(Wish.init)
    }

    @MainActor
    func suggestedEntities() throws -> [Wish] {
        try modelContainer.mainContext.fetch(FetchDescriptor<WishModel>()).map(Wish.init)
    }
}
