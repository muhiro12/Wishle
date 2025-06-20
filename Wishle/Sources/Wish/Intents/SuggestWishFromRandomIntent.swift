//
//  SuggestWishFromRandomIntent.swift
//  Wishle
//
//  Created by Codex on 2025/06/20.
//

import AppIntents
import FoundationModels
import SwiftData
import SwiftUtilities

@Generable
private struct RandomWishSuggestion: Decodable {
    var title: String
    var notes: String?
}

struct SuggestWishFromRandomIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Suggest Wish from Random"

    @Dependency private var modelContainer: ModelContainer

    typealias Input = ModelContext
    typealias Output = Wish

    static func perform(_ context: ModelContext) async throws -> Wish {
        var samples: [Wish] = []
        for _ in 0..<5 {
            let wish = try FetchRandomWishIntent.perform(context)
            samples.append(wish)
        }
        let prompt = samples.map { "- \($0.title)" }.joined(separator: "\n")
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: "Suggest a new wish based on these wishes:\n\(prompt)",
            generating: RandomWishSuggestion.self
        )
        return Wish(title: response.content.title, notes: response.content.notes)
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform(modelContainer.mainContext)
        return .result(value: wish.title)
    }
}
