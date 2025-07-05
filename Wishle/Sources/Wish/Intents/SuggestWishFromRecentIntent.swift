//
//  SuggestWishFromRecentIntent.swift
//  Wishle
//
//  Created by Codex on 2025/06/20.
//

import AppIntents
import Foundation
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

    nonisolated static let title: LocalizedStringResource = "Suggest Wish from Recent"

    static func perform(_ input: Input) async throws -> Wish {
        var descriptor = FetchDescriptor<WishModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let models = try input.fetch(descriptor)
        let recent = models.map(\.wish)
        let promptList = recent.map { "- \($0.title)" }.joined(separator: "\n")
        let prompt = PromptHelper.localized("Suggest a new wish based on these recent wishes:\n\(promptList)")
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: prompt,
            generating: RecentWishSuggestion.self
        )
        return Wish(title: response.content.title, notes: response.content.notes)
    }

    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform(modelContainer.mainContext)
        return .result(value: wish.title)
    }
}
