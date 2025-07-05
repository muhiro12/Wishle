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
    typealias Input = ModelContext
    typealias Output = Wish

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = "Suggest Wish from Random"

    static func perform(_ input: Input) async throws -> Wish {
        var samples: [Wish] = []
        for _ in 0..<5 {
            let wish = try FetchRandomWishIntent.perform(input)
            samples.append(wish)
        }
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let promptList = samples.map { "- \($0.title)" }.joined(separator: "\n")
        let prompt = "Respond in the user's device language: \(language). Suggest a new wish based on these wishes:\n\(promptList)"
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: prompt,
            generating: RandomWishSuggestion.self
        )
        return Wish(title: response.content.title, notes: response.content.notes)
    }

    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform(modelContainer.mainContext)
        return .result(value: wish.title)
    }
}
