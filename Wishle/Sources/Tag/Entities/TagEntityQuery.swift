//
//  TagEntityQuery.swift
//  Wishle
//
//  Created by Codex on 2025/06/29.
//

import AppIntents
import SwiftData

struct TagEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func entities(for identifiers: [Tag.ID]) throws -> [Tag] {
        try identifiers.compactMap { id in
            let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate { $0.id == id })
            return try modelContainer.mainContext.fetch(descriptor).first?.tag
        }
    }

    @MainActor
    func entities(matching string: String) throws -> [Tag] {
        try modelContainer.mainContext
            .fetch(FetchDescriptor<TagModel>(predicate: #Predicate { $0.name.localizedStandardContains(string) }))
            .map(\.tag)
    }

    @MainActor
    func suggestedEntities() throws -> [Tag] {
        try modelContainer.mainContext.fetch(FetchDescriptor<TagModel>()).map(\.tag)
    }
}

