//
//  SearchWishIntent.swift
//  Wishle
//
//  Created by Codex on 2025/06/21.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct SearchWishIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, query: String)
    typealias Output = [Wish]

    @Parameter(title: "Query")
    private var query: String

    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Search Wishes"

    static var parameterSummary: some ParameterSummary {
        Summary("Search wishes for \(\.$query)")
    }

    static func perform(_ input: Input) throws -> [Wish] {
        let (context, query) = input
        var descriptor = FetchDescriptor<WishModel>(
            predicate: #Predicate { model in
                model.title.localizedStandardContains(query) ||
                (model.notes ?? "").localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 20
        let models = try context.fetch(descriptor)
        return models.map(\.wish)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<[Wish]> {
        let wishes = try Self.perform((context: modelContainer.mainContext, query: query))
        return .result(value: wishes)
    }
}
