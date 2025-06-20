//
//  SuggestWishFromRecentIntent.swift
//  Wishle
//
//  Created by Codex on 2025/06/20.
//

import AppIntents
import FoundationModels
import SwiftData
import SwiftUtilities

@Generable
private struct RecentWishSuggestion: Decodable {
    var title: String
    var notes: String?
}

struct SuggestWishFromRecentIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Wish

    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Suggest Wish from Recent"

    static func perform(_ context: ModelContext) async throws -> Wish {
        var descriptor = FetchDescriptor<WishModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let models = try context.fetch(descriptor)
        let recent = models.map(\.wish)
        let prompt = recent.map { "- \($0.title)" }.joined(separator: "\n")
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: "Suggest a new wish based on these recent wishes:\n\(prompt)",
            generating: RecentWishSuggestion.self
        )
        return Wish(title: response.content.title, notes: response.content.notes)
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform(modelContainer.mainContext)
        return .result(value: wish.title)
    }
}
